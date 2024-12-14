from django.urls import path
from factbook import views

urlpatterns = [
    path("", views.index, name="index"),
]
