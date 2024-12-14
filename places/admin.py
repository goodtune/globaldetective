from django.contrib import admin

from places.models import City, Country


class CountryAdmin(admin.ModelAdmin):
    list_display = ("name", "common_name", "code", "currency")
    list_editable = ("common_name", "currency")
    list_filter = ("currency",)


class CityAdmin(admin.ModelAdmin):
    list_display = ("name", "country__common_name", "country__currency")
    list_filter = ("country__currency",)


admin.site.register(Country, CountryAdmin)
admin.site.register(City, CityAdmin)
