from django.shortcuts import get_object_or_404, render

from criminals.models import Suspect


def index(request):
    suspects = Suspect.objects.all()
    context = {"suspects": suspects}
    return render(request, "dossiers/index.html", context)


def suspect(request, name):
    suspect = get_object_or_404(Suspect, name=name)
    context = {"suspect": suspect}
    return render(request, "dossiers/suspect.html", context)
