enum struct ESFeatureContext
{
    ESFeature   Feature;
    ToggleState State;
    //StringMap   Value; /* Contains feature value */

    void Init(ESFeature feature, ToggleState state)
    {
        this.Feature        =   feature;
        this.State          =   state;
        /*this.Value          =   new StringMap();
        
        if(this.Feature.ValueType != STRING) this.Value.SetValue("Value", 0);
        else this.Value.SetString("Value", NULL_STRING);*/
    }
}