from typing import List, Dict, Optional
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.preprocessing import StandardScaler
import numpy as np
from datetime import datetime, timedelta
import pandas as pd
from enum import Enum

class RiskLevel(Enum):
    LOW = "low"
    MODERATE = "moderate"
    HIGH = "high"
    VERY_HIGH = "very_high"

class RecommendationEngine:
    def __init__(self):
        self.genetic_risk_model = RandomForestClassifier()
        self.lifestyle_model = GradientBoostingClassifier()
        self.scaler = StandardScaler()
        
        # Initialize genetic risk markers database
        self.genetic_markers = {
            # Cancer-related genes
            "BRCA1": {"cancer_types": ["breast", "ovarian"], "risk_factor": 5.0},
            "BRCA2": {"cancer_types": ["breast", "ovarian", "pancreatic"], "risk_factor": 4.5},
            "TP53": {"cancer_types": ["multiple"], "risk_factor": 5.0},
            "MLH1": {"cancer_types": ["colorectal"], "risk_factor": 4.0},
            "MSH2": {"cancer_types": ["colorectal", "endometrial"], "risk_factor": 4.0},
            
            # Cardiovascular genes
            "APOB": {"condition": "familial_hypercholesterolemia", "risk_factor": 4.0},
            "LDLR": {"condition": "heart_disease", "risk_factor": 3.5},
            "PCSK9": {"condition": "cholesterol_disorders", "risk_factor": 3.0},
            
            # Neurodegenerative markers
            "APOE-e4": {"condition": "alzheimers", "risk_factor": 4.5},
            "PSEN1": {"condition": "early_onset_alzheimers", "risk_factor": 5.0},
            "MAPT": {"condition": "frontotemporal_dementia", "risk_factor": 4.0},
            
            # Metabolic genes
            "TCF7L2": {"condition": "type2_diabetes", "risk_factor": 3.0},
            "MC4R": {"condition": "obesity", "risk_factor": 2.5},
            "FTO": {"condition": "obesity", "risk_factor": 2.0},
            
            # Autoimmune markers
            "HLA-DRB1": {"conditions": ["rheumatoid_arthritis", "multiple_sclerosis"], "risk_factor": 3.5},
            "CTLA4": {"conditions": ["type1_diabetes", "thyroid_disorders"], "risk_factor": 3.0},
            
            # Pharmacogenetic markers
            "CYP2D6": {"medication_metabolism": "multiple_drugs", "risk_factor": 3.0},
            "VKORC1": {"medication_metabolism": "warfarin", "risk_factor": 3.0},
        }

    def generate_recommendations(self, user_data: dict) -> Dict[str, List[dict]]:
        """Generate comprehensive health recommendations based on multiple data sources."""
        recommendations = {
            "critical": [],
            "high_priority": [],
            "preventive": [],
            "lifestyle": [],
            "genetic": [],
            "monitoring": []
        }
        
        # Analyze genetic risks
        if user_data.get("genetic_data"):
            genetic_risks = self._analyze_genetic_risks(user_data["genetic_data"])
            recommendations["genetic"].extend(genetic_risks)
        
        # Analyze lifestyle factors
        if user_data.get("lifestyle_data"):
            lifestyle_recs = self._analyze_lifestyle(user_data["lifestyle_data"])
            recommendations["lifestyle"].extend(lifestyle_recs)
        
        # Analyze medical history
        if user_data.get("medical_history"):
            medical_recs = self._analyze_medical_history(
                user_data["medical_history"],
                genetic_risks=recommendations["genetic"]
            )
            self._categorize_medical_recommendations(medical_recs, recommendations)
        
        # Analyze environmental factors
        if user_data.get("environmental_data"):
            env_recs = self._analyze_environmental_factors(user_data["environmental_data"])
            recommendations["preventive"].extend(env_recs)
        
        # Analyze recent health metrics
        if user_data.get("health_metrics"):
            metric_recs = self._analyze_health_metrics(user_data["health_metrics"])
            self._categorize_recommendations(metric_recs, recommendations)
        
        return recommendations

    def _analyze_genetic_risks(self, genetic_data: Dict[str, dict]) -> List[dict]:
        """Analyze genetic markers for health risks and recommendations."""
        risks = []
        
        for gene, data in genetic_data.items():
            if gene in self.genetic_markers:
                marker_info = self.genetic_markers[gene]
                variant = data.get("variant")
                
                if self._is_risk_variant(gene, variant):
                    risk = {
                        "gene": gene,
                        "risk_level": self._calculate_risk_level(marker_info["risk_factor"]),
                        "conditions": marker_info.get("cancer_types") or [marker_info.get("condition")],
                        "recommendations": self._get_genetic_recommendations(gene, variant)
                    }
                    risks.append(risk)
        
        return risks

    def _analyze_lifestyle(self, lifestyle_data: dict) -> List[dict]:
        """Analyze lifestyle factors and generate recommendations."""
        recommendations = []
        
        # Physical Activity Analysis
        activity_recs = self._analyze_physical_activity(lifestyle_data)
        recommendations.extend(activity_recs)
        
        # Diet Analysis
        diet_recs = self._analyze_diet(lifestyle_data)
        recommendations.extend(diet_recs)
        
        # Sleep Analysis
        sleep_recs = self._analyze_sleep(lifestyle_data)
        recommendations.extend(sleep_recs)
        
        # Stress Management
        stress_recs = self._analyze_stress_levels(lifestyle_data)
        recommendations.extend(stress_recs)
        
        # Substance Use
        substance_recs = self._analyze_substance_use(lifestyle_data)
        recommendations.extend(substance_recs)
        
        return recommendations

    def _analyze_medical_history(self, medical_history: dict, genetic_risks: List[dict]) -> List[dict]:
        """Analyze medical history and generate recommendations."""
        recommendations = []
        
        # Chronic Conditions Management
        if medical_history.get("chronic_conditions"):
            chronic_recs = self._analyze_chronic_conditions(
                medical_history["chronic_conditions"],
                genetic_risks
            )
            recommendations.extend(chronic_recs)
        
        # Medication Analysis
        if medical_history.get("medications"):
            med_recs = self._analyze_medications(
                medical_history["medications"],
                genetic_risks
            )
            recommendations.extend(med_recs)
        
        # Family History Analysis
        if medical_history.get("family_history"):
            family_recs = self._analyze_family_history(
                medical_history["family_history"],
                genetic_risks
            )
            recommendations.extend(family_recs)
        
        return recommendations

    def _analyze_health_metrics(self, metrics: Dict[str, List[float]]) -> List[dict]:
        """Analyze recent health metrics and generate recommendations."""
        recommendations = []
        
        # Vital Signs Analysis
        vitals_recs = self._analyze_vital_signs(metrics)
        recommendations.extend(vitals_recs)
        
        # Lab Results Analysis
        if metrics.get("lab_results"):
            lab_recs = self._analyze_lab_results(metrics["lab_results"])
            recommendations.extend(lab_recs)
        
        # Fitness Metrics Analysis
        if metrics.get("fitness_metrics"):
            fitness_recs = self._analyze_fitness_metrics(metrics["fitness_metrics"])
            recommendations.extend(fitness_recs)
        
        return recommendations

    def _get_genetic_recommendations(self, gene: str, variant: str) -> List[str]:
        """Get specific recommendations based on genetic variants."""
        recommendations = []
        
        if gene in self.genetic_markers:
            marker = self.genetic_markers[gene]
            
            # Cancer prevention recommendations
            if "cancer_types" in marker:
                for cancer_type in marker["cancer_types"]:
                    recommendations.extend(self._get_cancer_prevention_recs(cancer_type))
            
            # Cardiovascular recommendations
            if marker.get("condition") in ["heart_disease", "familial_hypercholesterolemia"]:
                recommendations.extend(self._get_cardiovascular_recs())
            
            # Neurodegenerative recommendations
            if marker.get("condition") in ["alzheimers", "frontotemporal_dementia"]:
                recommendations.extend(self._get_neurodegenerative_recs())
            
            # Metabolic recommendations
            if marker.get("condition") in ["type2_diabetes", "obesity"]:
                recommendations.extend(self._get_metabolic_recs())
        
        return recommendations

    # Additional helper methods would be implemented here...