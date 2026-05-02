from django import forms
from wastebins.models import WasteBin

class WasteBinForm(forms.ModelForm):
    class Meta:
        model = WasteBin
        fields = ['name', 'latitude', 'longitude', 'fill_level', 'status']

    latitude = forms.DecimalField(max_digits=20, decimal_places=15, required=False)
    longitude = forms.DecimalField(max_digits=20, decimal_places=15, required=False)
    
    class Media:
        css = {'all': ('https://unpkg.com/leaflet@1.9.4/dist/leaflet.css',)}
        js = ('https://unpkg.com/leaflet@1.9.4/dist/leaflet.js', 'admin/js/osm_map.js')
    
