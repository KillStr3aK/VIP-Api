enum struct ESFeatureContext
{
    ESFeature   Feature;
    ToggleState State;
    StringMap   Value; /* Contains feature value */

    void Init(ESFeature feature)
    {
        this.Feature        =   feature;
        this.State          =   NO_ACCESS;
        this.Value          =   new StringMap();
        
        if(Feature.ValueType != STRING) this.Value.SetValue("Value", 0);
        else this.Value.SetString("Value", NULL_STRING);
    }
}