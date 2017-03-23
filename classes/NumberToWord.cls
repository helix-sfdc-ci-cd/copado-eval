public without sharing class NumberToWord {
    static String[] lowNames = new string[]{
                'zero', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten',
                'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'};

    //private static final String[] tensNames = {
    static String[] tensNames = new string[]{
                'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'};

    //private static final String[] bigNames = {
    static String[] bigNames = new string[]{
                'Thousand', 'Million', 'Billion'};

    public static String convertNumberToWords (integer numberValue) {
        if (numberValue < 0){
            return 'minus ' + convertNumberToWords(-numberValue); 
        }
        if(numberValue <= 999){
            return convert999(numberValue); 
        }
        String retStr = null;
        integer t = 0;
        while (numberValue > 0) {
            if (math.mod(numberValue, 1000) != 0) {
                String s2 = convert999(math.mod(numberValue, 1000));
                if (t > 0){
                    s2 = s2 + ' ' + bigNames[t-1]; 
                }
                if (retStr == null){
                    retStr = s2; 
                }
                else{
                    retStr = s2 + ', ' + retStr; 
                }
            }
            numberValue /= 1000;
            t++; 
        }
        return retStr; 
    }

    // Range 0 to 999.
    private static String convert999 (integer numberValue) {
        String s1 = lowNames[numberValue / 100] + ' Hundred';
        String s2 = convert99(math.mod(numberValue, 100));
        if (numberValue <= 99) {
            return s2; 
        }
        else if (math.mod(numberValue, 100) == 0) {
            return s1; 
        }
        else {
            return s1 + ' ' + s2; 
        }
    }

    // Range 0 to 99.
    private static String convert99 (integer numberValue) {
        if (numberValue < 20) {
            return lowNames[numberValue]; 
        }
        String s = tensNames[numberValue / 10 - 2];
        if (math.mod(numberValue, 10) == 0) {
            return s; 
        }
        return s + '-' + lowNames[math.mod(numberValue, 10)]; 
    }
}