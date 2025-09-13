from django.urls import path
from . import views

app_name = "games"

urlpatterns = [
    path("", views.index, name="index"),
    path("globe/", views.globe_view, name="globe"),
    path("cases/", views.cases_list, name="cases_list"),
    path("cases/<int:case_id>/", views.case_briefing, name="case_briefing"),
    path("country/<str:country_code>/", views.country_detail, name="country_detail"),
    path("landmark/<int:landmark_id>/", views.landmark_detail, name="landmark_detail"),
    path("create/", views.create_session, name="create_session"),
    path("session/<uuid:session_id>/", views.session_detail, name="session_detail"),
    path("session/<uuid:session_id>/join/", views.join_session, name="join_session"),
    path("demo-login/", views.demo_login, name="demo_login"),
]