from django.urls import path

from game import views

app_name = "game"

urlpatterns = [
    path("", views.index, name="index"),
    path("new/", views.new_case, name="new"),
    path("case/", views.case, name="case"),
    path("investigate/", views.investigate, name="investigate"),
    path("speak/", views.speak, name="speak"),
    path("travel/", views.travel, name="travel"),
    path("warrant/", views.warrant, name="warrant"),
    path("arrest/", views.arrest, name="arrest"),
    path("result/", views.result, name="result"),
]
