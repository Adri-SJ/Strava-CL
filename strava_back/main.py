import os
from fastapi import FastAPI, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session, joinedload 
from passlib.context import CryptContext
from typing import Optional
import models, schemas, database # <--- Importante
from fastapi.staticfiles import StaticFiles
from sqlalchemy import func

app = FastAPI()

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
    db: Session = Depends(database.get_db) # <--- Usamos database.get_db
):
    actividad = db.query(models.Actividad).filter(models.Actividad.id == activi>
    if not actividad:
        raise HTTPException(status_code=404, detail="Actividad no encontrada")
    
    if foto:
        file_path = os.path.join(UPLOAD_DIR, f"{actividad_id}_{foto.filename}")
        with open(file_path, "wb") as buffer:
            content = await foto.read()
            buffer.write(content)
        actividad.ruta_foto = f"uploads/{actividad_id}_{foto.filename}" 

         actividad.titulo = titulo
    actividad.descripcion = descripcion
    actividad.distancia_km = distancia_km
    
    db.commit()
    db.refresh(actividad)
    return actividad

@app.get("/feed/")
def obtener_feed(db: Session = Depends(database.get_db)):
    return db.query(models.Actividad)\
             .options(joinedload(models.Actividad.puntos))\
             .order_by(models.Actividad.fecha.desc())\
             .all()

@app.get("/explorar/rutas/")
def obtener_todas_las_rutas(db: Session = Depends(database.get_db)):
    return db.query(models.Actividad).options(joinedload(models.Actividad.punto>

@app.post("/auth/register")
def register(user: schemas.UserCreate, db: Session = Depends(database.get_db)):
    db_user = db.query(models.Usuario).filter(models.Usuario.email == user.emai>
    if db_user:
        raise HTTPException(status_code=400, detail="El email ya está registrad>
    hashed = pwd_context.hash(user.password)
    new_user = models.Usuario(username=user.username, email=user.email, passwor>
    db.add(new_user)
    db.commit()
    return {"status": "Usuario creado exitosamente"}

@app.post("/auth/login")
def login(user_credentials: schemas.UserCreate, db: Session = Depends(database.>
    user = db.query(models.Usuario).filter(models.Usuario.email == user_credent>
    if not user or not pwd_context.verify(user_credentials.password, user.passw>
        raise HTTPException(status_code=403, detail="Credenciales inválidas")
    return {"message": "Login exitoso", "user_id": user.id, "username": user.us>

@app.post("/actividades/")
def crear_actividad(actividad: schemas.ActividadCreate, db: Session = Depends(d>
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
def registrar_punto(punto: schemas.PuntoCreate, db: Session = Depends(database.>
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
def obtener_mis_actividades(usuario_id: int, db: Session = Depends(database.get>
    return db.query(models.Actividad)\
             .filter(models.Actividad.usuario_id == usuario_id)\
             .options(joinedload(models.Actividad.puntos))\
             .order_by(models.Actividad.fecha.desc())\
             .all()

@app.get("/seguridad/heatmap")
def obtener_puntos_seguros(db: Session = Depends(database.get_db)):
    # Agregamos models. para que reconozca las tablas
    puntos = (
        db.query(models.PuntoRuta.latitud, models.PuntoRuta.longitud)
        .join(models.Actividad)
        .filter(models.Actividad.nivel_seguridad >= 4)
        .all()
    )
    return [{"lat": p.latitud, "lng": p.longitud} for p in puntos]

@app.put("/actividades/{actividad_id}/seguridad")
def calificar_seguridad(actividad_id: int, nivel: int, db: Session = Depends(da>
    actividad = db.query(models.Actividad).filter(models.Actividad.id == activi>
    if actividad:
        actividad.nivel_seguridad = nivel
        db.commit()
        return {"status": "ok"}
    return {"error": "No encontrada"}, 404

@app.post("/avisos/")
def crear_aviso(aviso: dict, db: Session = Depends(database.get_db)):
    nuevo_aviso = models.Aviso(
        usuario_id=aviso['usuario_id'],
        contenido=aviso['contenido'],
        categoria=aviso['categoria']
    )
    db.add(nuevo_aviso)
    db.commit()
    db.refresh(nuevo_aviso)
    return nuevo_aviso

@app.get("/avisos/")
def obtener_avisos(db: Session = Depends(database.get_db)):
    return db.query(models.Aviso).order_by(models.Aviso.fecha_creacion.desc()).>

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

