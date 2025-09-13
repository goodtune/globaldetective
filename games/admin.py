from django.contrib import admin
from .models import GameSession, Case, GameCase, Player, Clue, Travel, Landmark


@admin.register(GameSession)
class GameSessionAdmin(admin.ModelAdmin):
    list_display = ['name', 'host', 'status', 'max_players', 'created_at']
    list_filter = ['status', 'created_at']
    search_fields = ['name', 'host__username']


@admin.register(Case)
class CaseAdmin(admin.ModelAdmin):
    list_display = ['title', 'suspect', 'stolen_artifact', 'difficulty', 'target_country']
    list_filter = ['difficulty', 'target_country']
    search_fields = ['title', 'stolen_artifact', 'suspect__name']


@admin.register(GameCase)
class GameCaseAdmin(admin.ModelAdmin):
    list_display = ['session', 'case', 'is_current', 'solved', 'solved_at']
    list_filter = ['is_current', 'solved']


@admin.register(Player)
class PlayerAdmin(admin.ModelAdmin):
    list_display = ['user', 'session', 'rank', 'current_location', 'cases_solved']
    list_filter = ['rank', 'current_location']
    search_fields = ['user__username', 'session__name']


@admin.register(Clue)
class ClueAdmin(admin.ModelAdmin):
    list_display = ['case', 'country', 'clue_type', 'is_correct_path', 'difficulty_level']
    list_filter = ['clue_type', 'is_correct_path', 'difficulty_level']
    search_fields = ['case__title', 'country__common_name', 'text']


@admin.register(Travel)
class TravelAdmin(admin.ModelAdmin):
    list_display = ['player', 'from_country', 'to_country', 'transport_type', 'cost', 'timestamp']
    list_filter = ['transport_type', 'timestamp']
    search_fields = ['player__user__username']


@admin.register(Landmark)
class LandmarkAdmin(admin.ModelAdmin):
    list_display = ['name', 'city', 'coordinates_lat', 'coordinates_lng']
    list_filter = ['city__country']
    search_fields = ['name', 'city__name', 'description']