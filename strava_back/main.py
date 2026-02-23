from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from passlib.context import CryptContext
import models, schemas, database

app = FastAPI()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

@app.post("/auth/register")
def register(user: schemas.UserCreate, db: Session = Depends(database.get_db)):
    if not user.password:
        raise HTTPException(status_code=400, detail="Password requerido")
    hashed = pwd_context.hash(user.password)
    new_user = models.Usuario(
        username=user.username, 
        email=user.email, 
        password_hash=hashed
    )
    db.add(new_user)
    db.commit()
    return {"status": "Usuario creado en PostgreSQL"}

@app.post("/auth/login")
def login(user_credentials: schemas.UserCreate, db: Session = Depends(database.get_db)):
    # 1. Buscar al usuario por email en la base de datos
    user = db.query(models.Usuario).filter(models.Usuario.email == user_credentials.email).first()
    
    # 2. Si no existe el usuario, lanzamos error 403 (Prohibido)
    if not user:
        raise HTTPException(status_code=403, detail="Credenciales inválidas")
    
    # 3. Verificar si la contraseña coincide con el hash guardado
    if not pwd_context.verify(user_credentials.password, user.password_hash):
        raise HTTPException(status_code=403, detail="Credenciales inválidas")
    
    # 4. Login exitoso
    return {
        "message": "Login exitoso",
        "user_id": str(user.id),
        "username": user.username
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)