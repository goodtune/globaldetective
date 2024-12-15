from django.urls import path
from dossiers import views

urlpatterns = [
    path("", views.index, name="index"),
]
