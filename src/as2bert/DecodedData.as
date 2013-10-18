package as2bert {
import flash.utils.ByteArray;

public class DecodedData {

    static private const CHAR : String = "Char";
    static private const INT : String = "Int";
    static private const DOUBLE : String = "Double";
    static private const STRING : String = "String";
    static private const BINARY : String = "Binary";
    static private const DECODED_DATA : String = "DecodedData";

    private var _data : Array = [];

    private var _types : Array = [];

    internal var _binLength : int = 0;

    public function get length() : int { return _data.length; }

    public function get binLength() : int { return _binLength; }

    public function addChar(val : int) : void {
        _types.push(CHAR);
        _data.push(val);
    }

    public function getChar(index : int) : int {
        checkType(CHAR, index);
        return _data[index];
    }

    public function addInt(val : int) : void {
        _types.push(INT);
        _data.push(val);
    }

    public function getInt(index : int) : int {
        checkType(INT, index);
        return _data[index];
    }

    public function addDouble(val : Number) : void {
        _types.push(DOUBLE);
        _data.push(val);
    }

    public function getDouble(index : int) : Number {
        checkType(DOUBLE, index);
        return _data[index];
    }

    public function addString(val : String) : void {
        _types.push(STRING);
        _data.push(val);
    }

    public function getString(index : int) : String {
        checkType(STRING, index);
        return _data[index];
    }

    public function addBinary(val : ByteArray) : void {
        _types.push(BINARY);
        _data.push(val);
    }

    public function getBinary(index : int) : ByteArray {
        checkType(BINARY, index);
        return _data[index];
    }

    public function addDecodedData(val : DecodedData) : void {
        _types.push(DECODED_DATA);
        _data.push(val);
    }

    public function getDecodedData(index : int) : DecodedData {
        if(_data[index] == "") return new DecodedData();

        checkType(DECODED_DATA, index);
        return _data[index];
    }

    public function checkType(type : String, index : int) : void {
        if(index > length) {
            throw new As2BertError("ask for item at index " + index
                + ", but there are only " + length + " items");
        }
        if((type == "Int") && (_types[index] == "Char")) {
            // it's ok
            return;
        }
        if(type != _types[index]) {
            throw new As2BertError("ask for " + type + " at index " + index
                + ", but here is:" + showItem(index, ""));
        }
    }

    public function toString() : String { return showWithPadding(""); }

    private function showItem(index : int, padding : String) : String {
        var type : String = _types[index];
        var val : * = _data[index];
        if(val == null) val = "<null>";
        else {
            if(type == DECODED_DATA) return val.showWithPadding(padding + index + "-");
            if(type == STRING) { val = '"' + val + '"'; }
            if(type == BINARY) { val = showBinary(val); }
        }
        return padding + index + "-" + type + "--" + val + "\n";
    }

    private function showWithPadding(padding : String) : String {
        var res : String = padding + "DecodedData--\n";
        var itemPadding : String = padding + "----";
        for(var i : int = 0; i < length; i++) {
            var item : String = showItem(i, itemPadding);
            res += item;
        }
        return res;
    }

    private function showBinary(bin : ByteArray) : String {
        var res : String = '<';
        var arr : Array = [];
        for(var i : int = 0; i < bin.length; i++) {
            if(i < (bin.length - 1)) res += bin[i] + ",";
            else res += bin[i];
        }
        res += '>';
        return res;
    }
}
}
