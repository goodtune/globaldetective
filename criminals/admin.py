from django.contrib import admin
from django.utils.safestring import mark_safe
from criminals.models import Suspect


class SuspectAdmin(admin.ModelAdmin):
    list_display = ("photo", "name", "sex", "hobby", "hair", "feature", "auto")
    list_filter = ("sex", "hobby", "hair", "feature", "auto")
    list_display_links = ("name",)

    def photo(self, obj):
        if obj.has_picture:
            return mark_safe(f"<img src='/static/criminals/img/{obj.name}.jpg' width='100' />")
        return "No picture available"


admin.site.register(Suspect, SuspectAdmin)
