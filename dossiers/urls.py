from django.urls import path
from dossiers import views

app_name = "dossiers"

urlpatterns = [
    path("", views.index, name="index"),
    path("<str:name>/", views.suspect, name="suspect"),
]
