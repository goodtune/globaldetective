from django.contrib import admin
from places.models import City, Country, FlagColour


class CountryAdmin(admin.ModelAdmin):
    list_display = ("name", "common_name", "code", "currency", "get_flag_colours")
    list_editable = ("common_name", "currency")
    list_filter = ("currency",)

    def get_flag_colours(self, obj):
        return ", ".join([c.colour for c in obj.flag_colours.order_by("colour")])


class CityAdmin(admin.ModelAdmin):
    list_display = (
        "name",
        "country__common_name",
        "country__currency",
        "flag_colours",
    )
    list_filter = ("country__currency", "country__flag_colours")

    def flag_colours(self, obj):
        return ", ".join(
            [c.colour for c in obj.country.flag_colours.order_by("colour")]
        )


class FlagColourAdmin(admin.ModelAdmin):
    list_display = ("colour",)


admin.site.register(Country, CountryAdmin)
admin.site.register(City, CityAdmin)
admin.site.register(FlagColour, FlagColourAdmin)
