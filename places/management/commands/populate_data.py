from django.core.management.base import BaseCommand
from places.models import Country, City, FlagColour
from criminals.models import Suspect
from games.models import Landmark, Case, Clue


class Command(BaseCommand):
    help = 'Populate the database with sample data for Global Detective'

    def handle(self, *args, **options):
        self.stdout.write('Creating sample data for Global Detective...')
        
        # Create flag colours
        flag_colours = ['Red', 'Blue', 'White', 'Green', 'Yellow', 'Black', 'Orange']
        for colour in flag_colours:
            FlagColour.objects.get_or_create(colour=colour)
        
        # Create countries and cities
        countries_data = [
            {
                'name': 'United States of America',
                'common_name': 'United States',
                'code': 'US',
                'currency': 'USD',
                'capital': 'Washington D.C.',
                'continent': 'North America',
                'coordinates_lat': 39.8283,
                'coordinates_lng': -98.5795,
                'geography': 'Diverse landscapes including mountains, plains, deserts, and coastlines',
                'history': 'Founded in 1776, became a major world power in the 20th century',
                'exports': 'Technology, aircraft, soybeans, machinery',
                'government': 'Federal Presidential Republic',
                'cities': [
                    {'name': 'New York', 'is_capital': False, 'population': 8419000, 'lat': 40.7128, 'lng': -74.0060},
                    {'name': 'Washington D.C.', 'is_capital': True, 'population': 692683, 'lat': 38.9072, 'lng': -77.0369},
                    {'name': 'Los Angeles', 'is_capital': False, 'population': 3971883, 'lat': 34.0522, 'lng': -118.2437},
                    {'name': 'San Francisco', 'is_capital': False, 'population': 873965, 'lat': 37.7749, 'lng': -122.4194},
                ]
            },
            {
                'name': 'United Kingdom',
                'common_name': 'Britain',
                'code': 'GB',
                'currency': 'GBP',
                'capital': 'London',
                'continent': 'Europe',
                'coordinates_lat': 55.3781,
                'coordinates_lng': -3.4360,
                'geography': 'Island nation with rolling hills, mountains in Scotland and Wales',
                'history': 'Former British Empire, Industrial Revolution birthplace',
                'exports': 'Financial services, pharmaceuticals, automobiles',
                'government': 'Constitutional Monarchy',
                'cities': [
                    {'name': 'London', 'is_capital': True, 'population': 8982000, 'lat': 51.5074, 'lng': -0.1278},
                    {'name': 'Edinburgh', 'is_capital': False, 'population': 464990, 'lat': 55.9533, 'lng': -3.1883},
                    {'name': 'Manchester', 'is_capital': False, 'population': 547000, 'lat': 53.4808, 'lng': -2.2426},
                ]
            },
            {
                'name': 'French Republic',
                'common_name': 'France',
                'code': 'FR',
                'currency': 'EUR',
                'capital': 'Paris',
                'continent': 'Europe',
                'coordinates_lat': 46.2276,
                'coordinates_lng': 2.2137,
                'geography': 'Diverse landscapes from Alps to Mediterranean coast',
                'history': 'Center of European culture, French Revolution 1789',
                'exports': 'Wine, luxury goods, aircraft, tourism',
                'government': 'Semi-Presidential Republic',
                'cities': [
                    {'name': 'Paris', 'is_capital': True, 'population': 2161000, 'lat': 48.8566, 'lng': 2.3522},
                    {'name': 'Lyon', 'is_capital': False, 'population': 515695, 'lat': 45.7640, 'lng': 4.8357},
                    {'name': 'Nice', 'is_capital': False, 'population': 342637, 'lat': 43.7102, 'lng': 7.2620},
                ]
            },
            {
                'name': 'Japan',
                'common_name': 'Japan',
                'code': 'JP',
                'currency': 'JPY',
                'capital': 'Tokyo',
                'continent': 'Asia',
                'coordinates_lat': 36.2048,
                'coordinates_lng': 138.2529,
                'geography': 'Mountainous archipelago with active volcanoes',
                'history': 'Ancient culture, rapid modernization in 19th century',
                'exports': 'Electronics, automobiles, robotics, anime',
                'government': 'Constitutional Monarchy',
                'cities': [
                    {'name': 'Tokyo', 'is_capital': True, 'population': 13960000, 'lat': 35.6762, 'lng': 139.6503},
                    {'name': 'Kyoto', 'is_capital': False, 'population': 1475183, 'lat': 35.0116, 'lng': 135.7681},
                    {'name': 'Osaka', 'is_capital': False, 'population': 2691185, 'lat': 34.6937, 'lng': 135.5023},
                ]
            },
            {
                'name': 'Italian Republic',
                'common_name': 'Italy',
                'code': 'IT',
                'currency': 'EUR',
                'capital': 'Rome',
                'continent': 'Europe',
                'coordinates_lat': 41.8719,
                'coordinates_lng': 12.5674,
                'geography': 'Boot-shaped peninsula with Alps in north',
                'history': 'Roman Empire, Renaissance birthplace',
                'exports': 'Fashion, food products, machinery, tourism',
                'government': 'Parliamentary Republic',
                'cities': [
                    {'name': 'Rome', 'is_capital': True, 'population': 2873000, 'lat': 41.9028, 'lng': 12.4964},
                    {'name': 'Florence', 'is_capital': False, 'population': 383083, 'lat': 43.7696, 'lng': 11.2558},
                    {'name': 'Venice', 'is_capital': False, 'population': 261905, 'lat': 45.4408, 'lng': 12.3155},
                ]
            },
        ]
        
        for country_data in countries_data:
            cities_data = country_data.pop('cities')
            country, created = Country.objects.get_or_create(
                code=country_data['code'],
                defaults=country_data
            )
            if created:
                self.stdout.write(f'Created country: {country.common_name}')
            
            # Add flag colours
            if country.code == 'US':
                country.flag_colours.add('Red', 'White', 'Blue')
            elif country.code == 'GB':
                country.flag_colours.add('Red', 'White', 'Blue')
            elif country.code == 'FR':
                country.flag_colours.add('Blue', 'White', 'Red')
            elif country.code == 'JP':
                country.flag_colours.add('Red', 'White')
            elif country.code == 'IT':
                country.flag_colours.add('Green', 'White', 'Red')
            
            # Create cities
            for city_data in cities_data:
                city, created = City.objects.get_or_create(
                    name=city_data['name'],
                    country=country,
                    defaults={
                        'is_capital': city_data['is_capital'],
                        'population': city_data['population'],
                        'coordinates_lat': city_data['lat'],
                        'coordinates_lng': city_data['lng'],
                    }
                )
                if created:
                    self.stdout.write(f'Created city: {city.name}, {country.common_name}')
        
        # Create landmarks
        landmarks_data = [
            {'name': 'Statue of Liberty', 'city': 'New York', 'description': 'Symbol of freedom and democracy', 'cultural_significance': 'Gift from France, represents American ideals'},
            {'name': 'Times Square', 'city': 'New York', 'description': 'Bright lights and Broadway theaters', 'cultural_significance': 'Commercial and entertainment hub'},
            {'name': 'White House', 'city': 'Washington D.C.', 'description': 'Official residence of the US President', 'cultural_significance': 'Symbol of American government'},
            {'name': 'Lincoln Memorial', 'city': 'Washington D.C.', 'description': 'Memorial to President Abraham Lincoln', 'cultural_significance': 'Symbol of unity and freedom'},
            {'name': 'Big Ben', 'city': 'London', 'description': 'Famous clock tower at Parliament', 'cultural_significance': 'Icon of British democracy and timekeeping'},
            {'name': 'Tower Bridge', 'city': 'London', 'description': 'Iconic Victorian bridge over Thames', 'cultural_significance': 'Symbol of London engineering prowess'},
            {'name': 'Edinburgh Castle', 'city': 'Edinburgh', 'description': 'Historic fortress on Castle Rock', 'cultural_significance': 'Symbol of Scottish heritage and independence'},
            {'name': 'Eiffel Tower', 'city': 'Paris', 'description': 'Iron tower built for 1889 Exposition', 'cultural_significance': 'Symbol of French innovation and romance'},
            {'name': 'Louvre Museum', 'city': 'Paris', 'description': 'World famous art museum', 'cultural_significance': 'Home to Mona Lisa and cultural treasures'},
            {'name': 'Tokyo Tower', 'city': 'Tokyo', 'description': 'Communications tower inspired by Eiffel Tower', 'cultural_significance': 'Symbol of post-war Japanese recovery'},
            {'name': 'Senso-ji Temple', 'city': 'Tokyo', 'description': 'Ancient Buddhist temple', 'cultural_significance': 'Oldest temple in Tokyo, spiritual center'},
            {'name': 'Fushimi Inari Shrine', 'city': 'Kyoto', 'description': 'Thousands of red torii gates', 'cultural_significance': 'Sacred Shinto site dedicated to Inari'},
            {'name': 'Colosseum', 'city': 'Rome', 'description': 'Ancient Roman amphitheater', 'cultural_significance': 'Symbol of Roman Empire and gladiatorial games'},
            {'name': 'Trevi Fountain', 'city': 'Rome', 'description': 'Baroque fountain with coin-throwing tradition', 'cultural_significance': 'Symbol of wishes and Roman craftsmanship'},
            {'name': 'Ponte Vecchio', 'city': 'Florence', 'description': 'Medieval bridge with shops', 'cultural_significance': 'Symbol of Renaissance commerce and architecture'},
        ]
        
        for landmark_data in landmarks_data:
            try:
                city = City.objects.get(name=landmark_data['city'])
                landmark, created = Landmark.objects.get_or_create(
                    name=landmark_data['name'],
                    city=city,
                    defaults={
                        'description': landmark_data['description'],
                        'cultural_significance': landmark_data['cultural_significance'],
                    }
                )
                if created:
                    self.stdout.write(f'Created landmark: {landmark.name}')
            except City.DoesNotExist:
                self.stdout.write(f'City not found: {landmark_data["city"]}')
        
        # Create suspects
        suspects_data = [
            {
                'name': 'Carmen Sandiego',
                'sex': 'FEMALE',
                'hobby': 'CLIMBING',
                'hair': 'RED',
                'feature': 'RING',
                'auto': 'CONVERTIBLE',
                'food': 'SEAFOOD',
                'has_picture': True,
            },
            {
                'name': 'Victor Vector',
                'sex': 'MALE',
                'hobby': 'TENNIS',
                'hair': 'BROWN',
                'feature': 'SCAR',
                'auto': 'RACECAR',
                'food': 'MEXICAN',
                'has_picture': True,
            },
            {
                'name': 'Patty Larceny',
                'sex': 'FEMALE',
                'hobby': 'MUSIC',
                'hair': 'BLONDE',
                'feature': 'TATTOO',
                'auto': 'MOTORBIKE',
                'food': 'SEAFOOD',
                'has_picture': True,
            },
            {
                'name': 'Sly Boots',
                'sex': 'MALE',
                'hobby': 'SKYDIVE',
                'hair': 'BLACK',
                'feature': 'LIMP',
                'auto': 'LIMO',
                'food': 'MEXICAN',
                'has_picture': True,
            },
        ]
        
        for suspect_data in suspects_data:
            suspect, created = Suspect.objects.get_or_create(
                name=suspect_data['name'],
                defaults=suspect_data
            )
            if created:
                self.stdout.write(f'Created suspect: {suspect.name}')
        
        # Create cases
        cases_data = [
            {
                'title': 'The Missing Crown Jewels',
                'description': 'The British Crown Jewels have been stolen from the Tower of London!',
                'suspect_name': 'Carmen Sandiego',
                'stolen_artifact': 'Crown Jewels of England',
                'difficulty': 'DETECTIVE',
                'target_country': 'GB',
            },
            {
                'title': 'The Vanishing Venus',
                'description': 'The Venus de Milo has disappeared from the Louvre!',
                'suspect_name': 'Patty Larceny',
                'stolen_artifact': 'Venus de Milo statue',
                'difficulty': 'ROOKIE',
                'target_country': 'FR',
            },
            {
                'title': 'The Liberty Bell Heist',
                'description': 'Someone has stolen the Liberty Bell from Philadelphia!',
                'suspect_name': 'Victor Vector',
                'stolen_artifact': 'Liberty Bell',
                'difficulty': 'INSPECTOR',
                'target_country': 'US',
            },
        ]
        
        for case_data in cases_data:
            try:
                suspect = Suspect.objects.get(name=case_data['suspect_name'])
                country = Country.objects.get(code=case_data['target_country'])
                case, created = Case.objects.get_or_create(
                    title=case_data['title'],
                    defaults={
                        'description': case_data['description'],
                        'suspect': suspect,
                        'stolen_artifact': case_data['stolen_artifact'],
                        'difficulty': case_data['difficulty'],
                        'target_country': country,
                    }
                )
                if created:
                    self.stdout.write(f'Created case: {case.title}')
            except (Suspect.DoesNotExist, Country.DoesNotExist) as e:
                self.stdout.write(f'Error creating case {case_data["title"]}: {e}')
        
        self.stdout.write(self.style.SUCCESS('Successfully populated database with sample data!'))