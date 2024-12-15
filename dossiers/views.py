from django.shortcuts import render

from criminals.models import Suspect


# Create your views here.
def index(request):
    suspects = Suspect.objects.all()
    context = {"suspects": suspects}
    return render(request, "dossiers/index.html", context)
