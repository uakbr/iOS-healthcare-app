from fastapi import APIRouter

router = APIRouter(prefix="/recommendations", tags=["recommendations"])


@router.get("/")
async def get_recommendations():
    # Mock recommendations for testing
    return [
        "Increase daily water intake",
        "Add 30 minutes of cardio exercise",
        "Consider vitamin D supplementation"
    ]