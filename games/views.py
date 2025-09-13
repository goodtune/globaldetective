from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required
from django.contrib.auth import login
from django.contrib.auth.models import User
from django.contrib import messages
from django.utils import timezone
from .models import GameSession, Case, Player, Landmark, Clue
from places.models import Country, City
from criminals.models import Suspect
import random


def index(request):
    """Game lobby - shows available sessions and allows creating new ones"""
    active_sessions = GameSession.objects.filter(status__in=['WAITING', 'ACTIVE']).order_by('-created_at')
    completed_sessions = GameSession.objects.filter(status='COMPLETED').order_by('-completed_at')[:5]
    
    context = {
        'active_sessions': active_sessions,
        'completed_sessions': completed_sessions,
        'available_cases': Case.objects.all().count(),
        'countries_count': Country.objects.all().count(),
        'landmarks_count': Landmark.objects.all().count(),
    }
    return render(request, 'games/index.html', context)


def globe_view(request):
    """Interactive globe view showing countries and cities"""
    countries = Country.objects.prefetch_related('city_set').all()
    landmarks = Landmark.objects.select_related('city__country').all()
    
    context = {
        'countries': countries,
        'landmarks': landmarks,
    }
    return render(request, 'games/globe.html', context)


def country_detail(request, country_code):
    """Show detailed information about a country and its landmarks"""
    country = get_object_or_404(Country, code=country_code)
    cities = country.city_set.all()
    landmarks = Landmark.objects.filter(city__country=country)
    
    context = {
        'country': country,
        'cities': cities,
        'landmarks': landmarks,
    }
    return render(request, 'games/country_detail.html', context)


def landmark_detail(request, landmark_id):
    """Show detailed information about a specific landmark"""
    landmark = get_object_or_404(Landmark, id=landmark_id)
    
    context = {
        'landmark': landmark,
    }
    return render(request, 'games/landmark_detail.html', context)


@login_required
def create_session(request):
    """Create a new game session"""
    if request.method == 'POST':
        name = request.POST.get('name')
        max_players = int(request.POST.get('max_players', 4))
        budget = int(request.POST.get('budget', 5000))
        time_limit = int(request.POST.get('time_limit', 120))
        
        session = GameSession.objects.create(
            name=name,
            host=request.user,
            max_players=max_players,
            budget=budget,
            time_limit=time_limit,
        )
        
        # Automatically join the host as a player
        Player.objects.create(
            session=session,
            user=request.user,
            budget_remaining=budget,
        )
        
        messages.success(request, f'Game session "{name}" created successfully!')
        return redirect('games:session_detail', session_id=session.id)
    
    return render(request, 'games/create_session.html')


@login_required
def session_detail(request, session_id):
    """Show game session details and allow joining/playing"""
    session = get_object_or_404(GameSession, id=session_id)
    players = session.players.all()
    current_player = players.filter(user=request.user).first()
    
    context = {
        'session': session,
        'players': players,
        'current_player': current_player,
        'can_join': not current_player and players.count() < session.max_players,
        'is_host': session.host == request.user,
    }
    return render(request, 'games/session_detail.html', context)


@login_required
def join_session(request, session_id):
    """Join an existing game session"""
    session = get_object_or_404(GameSession, id=session_id)
    
    if session.players.count() >= session.max_players:
        messages.error(request, 'This session is full!')
        return redirect('games:session_detail', session_id=session_id)
    
    if session.players.filter(user=request.user).exists():
        messages.warning(request, 'You are already in this session!')
        return redirect('games:session_detail', session_id=session_id)
    
    Player.objects.create(
        session=session,
        user=request.user,
        budget_remaining=session.budget,
    )
    
    messages.success(request, f'Joined session "{session.name}"!')
    return redirect('games:session_detail', session_id=session_id)


def demo_login(request):
    """Demo login for testing purposes"""
    username = request.GET.get('username', 'detective1')
    user, created = User.objects.get_or_create(
        username=username,
        defaults={'first_name': username.title(), 'email': f'{username}@globaldetective.com'}
    )
    login(request, user)
    messages.success(request, f'Logged in as {user.username}!')
    return redirect('games:index')