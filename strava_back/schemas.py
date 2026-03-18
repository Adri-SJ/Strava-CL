from pydantic import BaseModel, EmailStr
from typing import Optional

class UserCreate(BaseModel):
    username: str
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: int
    username: str
    email: str

    class Config:
        orm_mode = True

class ActividadCreate(BaseModel):
    tipo_deporte: str
    distancia_total: float = 0.0
    usuario_id: int

class PuntoCreate(BaseModel):
    actividad_id: int
    latitud: float
    longitud: float
    orden: int

class ActividadUpdate(BaseModel):
    titulo: str
    descripcion: Optional[str] = None
    distancia_km: float
    ruta_foto : Optional[str] = None

    class Config:
        from_attributes = True 