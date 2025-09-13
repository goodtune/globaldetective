from django.core.management.base import BaseCommand
from games.models import Case, Clue
from places.models import Country


class Command(BaseCommand):
    help = 'Create sample clues for detective cases'

    def handle(self, *args, **options):
        self.stdout.write('Creating sample clues for cases...')
        
        # Get the cases
        try:
            crown_jewels_case = Case.objects.get(title="The Missing Crown Jewels")
            venus_case = Case.objects.get(title="The Vanishing Venus")
            liberty_bell_case = Case.objects.get(title="The Liberty Bell Heist")
        except Case.DoesNotExist:
            self.stdout.write(self.style.ERROR('Cases not found. Run populate_data first.'))
            return
        
        # Crown Jewels Case Clues (Carmen Sandiego in Britain)
        crown_clues = [
            {
                'country_code': 'US',
                'clue_type': 'CULTURAL',
                'text': 'A witness saw a woman in a red trenchcoat asking about the best routes to London. She mentioned wanting to see the changing of the guard.',
                'is_correct_path': True,
                'difficulty_level': 2
            },
            {
                'country_code': 'FR',
                'clue_type': 'CULTURAL',
                'text': 'Someone overheard a conversation about "crossing the Channel" and "visiting the Queen\'s treasures." The accent was distinctly American.',
                'is_correct_path': True,
                'difficulty_level': 3
            },
            {
                'country_code': 'IT',
                'clue_type': 'GEOGRAPHIC',
                'text': 'A red-haired tourist was seen studying a map of northern Europe, circling islands off the coast of France.',
                'is_correct_path': False,
                'difficulty_level': 1
            },
            {
                'country_code': 'JP',
                'clue_type': 'HISTORICAL',
                'text': 'Local guides report someone asking about ancient imperial treasures and mentioning "the crown that never sets."',
                'is_correct_path': False,
                'difficulty_level': 2
            },
            {
                'country_code': 'GB',
                'clue_type': 'CURRENT_EVENTS',
                'text': 'FINAL CLUE: Security footage shows our suspect near the Tower of London. Time to make the arrest!',
                'is_correct_path': True,
                'difficulty_level': 1
            }
        ]
        
        # Venus Case Clues (Patty Larceny in France)
        venus_clues = [
            {
                'country_code': 'US',
                'clue_type': 'CULTURAL',
                'text': 'A blonde woman was overheard at an art gallery saying "The Louvre has nothing on what I\'m planning." She drove away on a motorcycle.',
                'is_correct_path': True,
                'difficulty_level': 1
            },
            {
                'country_code': 'GB',
                'clue_type': 'HISTORICAL',
                'text': 'Museum visitors report seeing someone photographing ancient Greek statues and muttering about "bringing art home."',
                'is_correct_path': False,
                'difficulty_level': 2
            },
            {
                'country_code': 'IT',
                'clue_type': 'GEOGRAPHIC',
                'text': 'A tourist asked locals about the fastest route to "the city of lights" and whether there were good motorcycle routes through the Alps.',
                'is_correct_path': True,
                'difficulty_level': 3
            },
            {
                'country_code': 'JP',
                'clue_type': 'CULTURAL',
                'text': 'Someone was seen studying European art books and asking about shipping costs to "the fashion capital of Europe."',
                'is_correct_path': False,
                'difficulty_level': 2
            },
            {
                'country_code': 'FR',
                'clue_type': 'CURRENT_EVENTS',
                'text': 'FINAL CLUE: The Louvre security reports a suspicious blonde woman casing the Venus de Milo exhibit. She\'s here!',
                'is_correct_path': True,
                'difficulty_level': 1
            }
        ]
        
        # Liberty Bell Case Clues (Victor Vector in USA)
        liberty_clues = [
            {
                'country_code': 'GB',
                'clue_type': 'HISTORICAL',
                'text': 'A man with a scar was heard saying "Time to take back what the colonies stole" while studying American independence exhibits.',
                'is_correct_path': True,
                'difficulty_level': 2
            },
            {
                'country_code': 'FR',
                'clue_type': 'CULTURAL',
                'text': 'Someone asked about the history of American independence and whether "liberty" could be "borrowed" for a good cause.',
                'is_correct_path': True,
                'difficulty_level': 3
            },
            {
                'country_code': 'IT',
                'clue_type': 'GEOGRAPHIC',
                'text': 'A tourist inquired about the distance between Rome and "the city of brotherly love," mentioning something about bells.',
                'is_correct_path': False,
                'difficulty_level': 2
            },
            {
                'country_code': 'JP',
                'clue_type': 'ECONOMIC',
                'text': 'A man driving a race car asked about shipping heavy bronze items to "the land of the rising yen." Suspicious timing.',
                'is_correct_path': False,
                'difficulty_level': 1
            },
            {
                'country_code': 'US',
                'clue_type': 'CURRENT_EVENTS',
                'text': 'FINAL CLUE: Philadelphia police report a man with a scar near Independence Hall. He was asking about the Liberty Bell\'s schedule!',
                'is_correct_path': True,
                'difficulty_level': 1
            }
        ]
        
        # Create clues for each case
        cases_and_clues = [
            (crown_jewels_case, crown_clues),
            (venus_case, venus_clues),
            (liberty_bell_case, liberty_clues)
        ]
        
        for case, clues_data in cases_and_clues:
            self.stdout.write(f'Creating clues for: {case.title}')
            
            for clue_data in clues_data:
                try:
                    country = Country.objects.get(code=clue_data['country_code'])
                    clue, created = Clue.objects.get_or_create(
                        case=case,
                        country=country,
                        clue_type=clue_data['clue_type'],
                        defaults={
                            'text': clue_data['text'],
                            'is_correct_path': clue_data['is_correct_path'],
                            'difficulty_level': clue_data['difficulty_level'],
                        }
                    )
                    if created:
                        self.stdout.write(f'  ✓ Created clue in {country.common_name}')
                    else:
                        self.stdout.write(f'  - Clue already exists in {country.common_name}')
                except Country.DoesNotExist:
                    self.stdout.write(f'  ✗ Country {clue_data["country_code"]} not found')
        
        self.stdout.write(self.style.SUCCESS('Successfully created sample clues!'))