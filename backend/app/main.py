from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import users, health_data, recommendations

app = FastAPI(title="Personalized Healthcare API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(users.router)
app.include_router(health_data.router)
app.include_router(recommendations.router)

@app.get("/")
async def root():
    return {"message": "Welcome to Personalized Healthcare API"} 