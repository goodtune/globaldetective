from django.contrib import admin

from criminals.models import Suspect


class SuspectAdmin(admin.ModelAdmin):
    list_display = ("name", "sex", "hobby", "hair", "feature", "auto")
    list_filter = ("sex", "hobby", "hair", "feature", "auto")


admin.site.register(Suspect, SuspectAdmin)
