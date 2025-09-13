from django.db import models
from django.contrib.auth.models import User
from criminals.models import Suspect
from places.models import Country, City
import uuid


class GameSession(models.Model):
    """Represents a multiplayer game session"""
    STATUS_CHOICES = [
        ('WAITING', 'Waiting for Players'),
        ('ACTIVE', 'Active'),
        ('COMPLETED', 'Completed'),
        ('PAUSED', 'Paused'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100)
    host = models.ForeignKey(User, on_delete=models.CASCADE, related_name='hosted_games')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='WAITING')
    max_players = models.PositiveIntegerField(default=4)
    budget = models.PositiveIntegerField(default=5000)  # Starting budget in dollars
    time_limit = models.PositiveIntegerField(default=120)  # Time limit in minutes
    created_at = models.DateTimeField(auto_now_add=True)
    started_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    def __str__(self):
        return f"{self.name} ({self.status})"


class Case(models.Model):
    """Represents a detective case/mission"""
    DIFFICULTY_CHOICES = [
        ('ROOKIE', 'Rookie'),
        ('DETECTIVE', 'Detective'),
        ('INSPECTOR', 'Inspector'),
        ('CHIEF', 'Chief Inspector'),
    ]
    
    title = models.CharField(max_length=200)
    description = models.TextField()
    suspect = models.ForeignKey(Suspect, on_delete=models.CASCADE)
    stolen_artifact = models.CharField(max_length=200)
    difficulty = models.CharField(max_length=20, choices=DIFFICULTY_CHOICES, default='ROOKIE')
    target_country = models.ForeignKey(Country, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.title} - {self.stolen_artifact}"


class GameCase(models.Model):
    """Links a case to a game session"""
    session = models.ForeignKey(GameSession, on_delete=models.CASCADE)
    case = models.ForeignKey(Case, on_delete=models.CASCADE)
    is_current = models.BooleanField(default=False)
    solved = models.BooleanField(default=False)
    solved_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        unique_together = ['session', 'case']


class Player(models.Model):
    """Represents a player in a game session"""
    RANK_CHOICES = [
        ('ROOKIE', 'Rookie Detective'),
        ('DETECTIVE', 'Detective'),
        ('SENIOR', 'Senior Detective'),
        ('INSPECTOR', 'Inspector'),
        ('CHIEF', 'Chief Inspector'),
    ]
    
    session = models.ForeignKey(GameSession, on_delete=models.CASCADE, related_name='players')
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    rank = models.CharField(max_length=20, choices=RANK_CHOICES, default='ROOKIE')
    current_location = models.ForeignKey(Country, on_delete=models.SET_NULL, null=True, blank=True)
    budget_remaining = models.PositiveIntegerField(default=0)
    cases_solved = models.PositiveIntegerField(default=0)
    joined_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        unique_together = ['session', 'user']
    
    def __str__(self):
        return f"{self.user.username} - {self.rank}"


class Clue(models.Model):
    """Represents a clue that can be discovered"""
    CLUE_TYPES = [
        ('GEOGRAPHIC', 'Geographic'),
        ('CULTURAL', 'Cultural'),
        ('HISTORICAL', 'Historical'),
        ('CURRENT_EVENTS', 'Current Events'),
        ('ECONOMIC', 'Economic'),
    ]
    
    case = models.ForeignKey(Case, on_delete=models.CASCADE, related_name='clues')
    country = models.ForeignKey(Country, on_delete=models.CASCADE)
    clue_type = models.CharField(max_length=20, choices=CLUE_TYPES)
    text = models.TextField()
    is_correct_path = models.BooleanField(default=False)
    difficulty_level = models.PositiveIntegerField(default=1)  # 1-5 scale
    
    def __str__(self):
        return f"{self.case.title} - {self.country.common_name} clue"


class Travel(models.Model):
    """Represents player travel between countries"""
    TRANSPORT_CHOICES = [
        ('FLIGHT_DIRECT', 'Direct Flight'),
        ('FLIGHT_CONNECTING', 'Connecting Flight'),
        ('TRAIN', 'Train'),
        ('SHIP', 'Ship'),
        ('CAR', 'Car'),
    ]
    
    player = models.ForeignKey(Player, on_delete=models.CASCADE, related_name='travels')
    from_country = models.ForeignKey(Country, on_delete=models.CASCADE, related_name='departures')
    to_country = models.ForeignKey(Country, on_delete=models.CASCADE, related_name='arrivals')
    transport_type = models.CharField(max_length=20, choices=TRANSPORT_CHOICES)
    cost = models.PositiveIntegerField()
    travel_time = models.PositiveIntegerField()  # in minutes
    timestamp = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.player.user.username}: {self.from_country.common_name} → {self.to_country.common_name}"


class Landmark(models.Model):
    """Represents landmarks within cities"""
    name = models.CharField(max_length=200)
    city = models.ForeignKey(City, on_delete=models.CASCADE, related_name='landmarks')
    description = models.TextField()
    image_url = models.URLField(blank=True, null=True)
    cultural_significance = models.TextField(blank=True)
    coordinates_lat = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    coordinates_lng = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    
    def __str__(self):
        return f"{self.name} ({self.city.name})"