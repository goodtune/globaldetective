from django.shortcuts import render

from places.models import Country


def index(request):
    countries = Country.objects.all()
    context = {"countries": countries}
    return render(request, "factbook/index.html", context)
