from sqlalchemy import Column, String, Float, Integer, Boolean, ForeignKey, Dat>
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from geoalchemy2 import Geography
import uuid
from database import Base
import datetime

class Usuario(Base):
    __tablename__ = "usuarios"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, nullable=False)
    email = Column(String, unique=True, nullable=False)
    password = Column(String, nullable=False)

class Actividad(Base):
    __tablename__ = "actividades"
    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"))
    titulo = Column(String)
    descripcion = Column(String)
    distancia_km = Column(Float, default=0.0)
    fecha = Column(DateTime(timezone=True), server_default=func.now())
    ruta_foto = Column(String, nullable=True)
    puntos = relationship("PuntoRuta", back_populates="actividad")
    nivel_seguridad = Column(Integer, default=3) # Escala del 1 al 5
    es_comunidad_uach = Column(Boolean, default=True) # Tropicalización Anáhuac

class PuntoRuta(Base):
    __tablename__ = "puntos_ruta"
    id = Column(Integer, primary_key=True, index=True)
    actividad_id = Column(Integer, ForeignKey("actividades.id"))
    latitud = Column(Float, nullable=False)
    longitud = Column(Float, nullable=False)
    orden_secuencia = Column(Integer)
    actividad = relationship("Actividad", back_populates="puntos")

class Aviso(Base):
    __tablename__ = "avisos"
    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"))
    contenido = Column(String)
    categoria = Column(String) # 'Seguridad', 'Evento', 'Compañero de ruta'
    fecha_creacion = Column(DateTime, default=func.now())

