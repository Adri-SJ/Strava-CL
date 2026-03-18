import os
from fastapi import FastAPI, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session, joinedload
from passlib.context import CryptContext
from typing import Optional 
import models, schemas, database
from fastapi.staticfiles import StaticFiles

app = FastAPI()

# Montar carpeta de fotos para que sean accesibles desde el celular
UPLOAD_DIR = "uploads"
if not os.path.exists(UPLOAD_DIR):
    os.makedirs(UPLOAD_DIR)
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

@app.put("/actividades/{actividad_id}")
async def finalizar_actividad(
    actividad_id: int, 
    titulo: str = Form(...), 
    descripcion: Optional[str] = Form(None), 
    distancia_km: float = Form(...),
    foto: Optional[UploadFile] = File(None), 
    db: Session = Depends(database.get_db)
):
    actividad = db.query(models.Actividad).filter(models.Actividad.id == actividad_id).first()
    if not actividad:
        raise HTTPException(status_code=404, detail="Actividad no encontrada")
    
    if foto:
        # Guardamos la foto en el servidor
        file_path = os.path.join(UPLOAD_DIR, f"{actividad_id}_{foto.filename}")
        with open(file_path, "wb") as buffer:
            content = await foto.read()
            buffer.write(content)
        # Guardamos la ruta relativa para que el celular la pida
        actividad.ruta_foto = f"uploads/{actividad_id}_{foto.filename}" 

    actividad.titulo = titulo
    actividad.descripcion = descripcion
    actividad.distancia_km = distancia_km
    
    db.commit()
    db.refresh(actividad)
    return actividad

@app.get("/feed/")
def obtener_feed(db: Session = Depends(database.get_db)):
    # Esto hace que el JSON incluya la lista de coordenadas para el mapa
    return db.query(models.Actividad)\
             .options(joinedload(models.Actividad.puntos))\
             .order_by(models.Actividad.fecha.desc())\
             .all()

@app.get("/explorar/rutas/")
def obtener_todas_las_rutas(db: Session = Depends(database.get_db)):
    # Usamos joinedload para traer los puntos GPS de cada ruta de una vez
    return db.query(models.Actividad).options(joinedload(models.Actividad.puntos)).all()

@app.post("/auth/register")
def register(user: schemas.UserCreate, db: Session = Depends(database.get_db)):
    db_user = db.query(models.Usuario).filter(models.Usuario.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="El email ya está registrado")
    hashed = pwd_context.hash(user.password)
    new_user = models.Usuario(username=user.username, email=user.email, password=hashed)
    db.add(new_user)
    db.commit()
    return {"status": "Usuario creado exitosamente"}

@app.post("/auth/login")
def login(user_credentials: schemas.UserCreate, db: Session = Depends(database.get_db)):
    user = db.query(models.Usuario).filter(models.Usuario.email == user_credentials.email).first()
    if not user or not pwd_context.verify(user_credentials.password, user.password):
        raise HTTPException(status_code=403, detail="Credenciales inválidas")
    return {"message": "Login exitoso", "user_id": user.id, "username": user.username}

@app.post("/actividades/")
def crear_actividad(actividad: schemas.ActividadCreate, db: Session = Depends(database.get_db)):
    nueva_activa = models.Actividad(
        titulo=actividad.tipo_deporte,
        distancia_km=actividad.distancia_total,
        usuario_id=actividad.usuario_id
        )
    db.add(nueva_activa)
    db.commit()
    db.refresh(nueva_activa)
    return nueva_activa

@app.post("/puntos-ruta/")
def registrar_punto(punto: schemas.PuntoCreate, db: Session = Depends(database.get_db)):
    nuevo_punto = models.PuntoRuta(
        actividad_id=punto.actividad_id,
        latitud=punto.latitud,
        longitud=punto.longitud,
        orden_secuencia=punto.orden
    )
    db.add(nuevo_punto)
    db.commit()
    return {"status": "coordenada guardada"}

@app.get("/usuarios/{usuario_id}/actividades")
def obtener_mis_actividades(usuario_id: int, db: Session = Depends(database.get_db)):
    return db.query(models.Actividad)\
             .filter(models.Actividad.usuario_id == usuario_id)\
             .options(joinedload(models.Actividad.puntos))\
             .order_by(models.Actividad.fecha.desc())\
             .all()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)