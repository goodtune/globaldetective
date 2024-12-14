from django.db import models


class Country(models.Model):
    name = models.CharField("Official Name", max_length=100)
    common_name = models.CharField("Common Name", max_length=50, blank=True, null=True)
    code = models.CharField(max_length=2)
    currency = models.CharField(max_length=20, blank=True, null=True)
    flora = models.TextField(blank=True, null=True)
    fauna = models.TextField(blank=True, null=True)
    geography = models.TextField(blank=True, null=True)
    exports = models.TextField(blank=True, null=True)
    flag_colours = models.ManyToManyField("FlagColour", blank=True)

    def __str__(self):
        return self.name

    class Meta:
        verbose_name_plural = "Countries"


class City(models.Model):
    name = models.CharField(max_length=100)
    country = models.ForeignKey(Country, on_delete=models.CASCADE)

    def __str__(self):
        return self.name

    class Meta:
        verbose_name_plural = "Cities"


class FlagColour(models.Model):
    colour = models.CharField(max_length=20, primary_key=True)

    def __str__(self):
        return self.colour

    class Meta:
        verbose_name_plural = "Flag Colours"
