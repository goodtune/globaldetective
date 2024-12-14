from django.db import models


class Sex(models.TextChoices):
    MALE = "MALE", "Male"
    FEMALE = "FEMALE", "Female"


class Hobby(models.TextChoices):
    TENNIS = "TENNIS", "Tennis"
    MUSIC = "MUSIC", "Music"
    CLIMBING = "CLIMBING", "Mountain Climbing"
    SKYDIVE = "SKYDIVE", "Skydiving"
    SWIMMING = "SWIMMING", "Swimming"
    CROQUET = "CROQUET", "Croquet"


class Hair(models.TextChoices):
    BROWN = "BROWN", "Brown"
    BLONDE = "BLONDE", "Blonde"
    RED = "RED", "Red"
    BLACK = "BLACK", "Black"
    GREY = "GREY", "Grey"


class Feature(models.TextChoices):
    LIMP = "LIMP", "Limps"
    RING = "RING", "Ring"
    TATTOO = "TATTOO", "Tattoo"
    SCAR = "SCAR", "Scar"
    JEWELERY = "JEWELERY", "Jewelery"


class Auto(models.TextChoices):
    CONVERTIBLE = "CONVERTIBLE", "Convertible"
    LIMO = "LIMO", "Limousine"
    RACECAR = "RACECAR", "Racecar"
    MOTORBIKE = "MOTORBIKE", "Motorcycle"


class Suspect(models.Model):
    name = models.CharField(max_length=100)
    sex = models.CharField(
        choices=Sex.choices,
        max_length=20,
        db_index=True,
    )
    hobby = models.CharField(
        choices=Hobby.choices,
        max_length=20,
        db_index=True,
        null=True,
        blank=True,
    )
    hair = models.CharField(
        choices=Hair.choices,
        max_length=20,
        db_index=True,
        null=True,
        blank=True,
    )
    feature = models.CharField(
        choices=Feature.choices,
        max_length=20,
        db_index=True,
        null=True,
        blank=True,
    )
    auto = models.CharField(
        choices=Auto.choices,
        max_length=20,
        db_index=True,
        null=True,
        blank=True,
    )

    def __str__(self):
        return self.name
