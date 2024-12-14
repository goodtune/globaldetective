from django.shortcuts import get_object_or_404, render

from places.models import Country


def index(request):
    countries = Country.objects.all()
    context = {"countries": countries}
    return render(request, "factbook/index.html", context)


def country(request, code):
    country = get_object_or_404(Country, code=code)
    context = {"country": country}
    return render(request, "factbook/country.html", context)
