from django.contrib import admin

from places.models import City, Country


class CountryAdmin(admin.ModelAdmin):
    list_display = ("name", "code")


class CityAdmin(admin.ModelAdmin):
    list_display = ("name", "country")


admin.site.register(Country, CountryAdmin)
admin.site.register(City, CityAdmin)
