package as2bert {
import flash.utils.ByteArray;

public class As2Bert {

    static public function encChar(val : uint) : ByteArray {
        var data : ByteArray = new ByteArray();
        data.writeByte(97);
        data.writeByte(val);
        data.position = 0;
        return data;
    }

    static public function decChar(data : ByteArray) : uint {
        if(data.bytesAvailable < 2)
            throw new As2BertError("Can't decode char, not enough data: " + data.bytesAvailable);
        var header : uint = data.readByte();
        if(header != 97) throw new As2BertError("Can't decode char, invalid header:" + header);
        return data.readUnsignedByte();
    }

    static public function encInt(val : int) : ByteArray {
        var data : ByteArray = new ByteArray();
        data.writeByte(98);
        data.writeInt(val);
        data.position = 0;
        return data;
    }

    static public function decInt(data : ByteArray) : int {
        if(data.bytesAvailable < 5)
            throw new As2BertError("Can't decode int, not enough data " + data.bytesAvailable);
        var header : uint = data.readByte();
        if(header != 98) throw new As2BertError("Can't decode int, invalid header:" + header);
        return data.readInt();
    }

    static public function encFloat(val : Number) : ByteArray {
        var data : ByteArray = new ByteArray();
        data.writeByte(99);
        var str : String = val.toExponential(20);
        data.writeUTFBytes(str);
        while(data.length < 32) data.writeByte(0);
        data.position = 0;
        return data;
    }

    static public function decFloat(data : ByteArray) : Number {
        if(data.bytesAvailable < 32)
            throw new As2BertError("Can't decode Float, not enough data " + data.bytesAvailable);
        var header : uint = data.readByte();
        if(header != 99) throw new As2BertError("Can't decode Float, invalid header:" + header);
        var str : String = data.readUTFBytes(31);
        return Number(str);
    }

    static public function encDouble(val : Number) : ByteArray {
        var data : ByteArray = new ByteArray();
        data.writeByte(70);
        data.writeDouble(val);
        data.position = 0;
        return data;
    }

    static public function decDouble(data : ByteArray) : Number {
        if(data.bytesAvailable < 9)
            throw new As2BertError("Can't decode Double, not enough data " + data.bytesAvailable);
        var header : uint = data.readByte();
        if(header != 70) throw new As2BertError("Can't decode Double, invalid header:" + header);
        return data.readDouble();
    }

    static public function encString(val : String) : ByteArray {
        var data : ByteArray = new ByteArray();
        if(val == "") {
            data.writeByte(106);
        }
        else {
            data.writeByte(107);
            data.writeUTF(val);
        }
        data.position = 0;
        return data;
    }

    static public function decString(data : ByteArray) : String {
        var header : uint = data.readByte();
        if(header == 106) return "";

        if(header != 107) throw new As2BertError("Can't decode String, invalid header:" + header);
        return data.readUTF();
    }

    static public function encAtom(val : String) : ByteArray {
        var data : ByteArray = new ByteArray();
        data.writeByte(100);
        data.writeUTF(val);
        data.position = 0;
        return data;
    }

    static public function decAtom(data : ByteArray) : String {
        var header : uint = data.readByte();
        if(header != 100) throw new As2BertError("Can't decode Atom, invalid header:" + header);
        return data.readUTF();
    }

    static public function encBin(val : ByteArray) : ByteArray {
        var data : ByteArray = new ByteArray();
        data.writeByte(109);
        if(val != null) {
            data.writeInt(val.length);
            data.writeBytes(val);
        }
        else data.writeInt(0);
        data.position = 0;
        return data;
    }

    static public function decBin(val : ByteArray) : ByteArray {
        var header : uint = val.readByte();
        if(header != 109) throw new As2BertError("Can't decode Binary, invalid header:" + header);

        var len : int = val.readInt();
        var data : ByteArray = new ByteArray();
        if(len > 0) {
            val.readBytes(data, 0, len);
            data.position = 0;
        }
        return data;
    }

    static public function encBStr(val : String) : ByteArray {
        var data : ByteArray = new ByteArray();
        data.writeUTFBytes(val);
        data.position = 0;
        return encBin(data);
    }

    static public function decBStr(val : ByteArray) : String {
        var data : ByteArray = decBin(val);
        return data.readUTFBytes(data.length);
    }

    static public function encTuple(items : Array) : ByteArray {
        var data : ByteArray = new ByteArray();
        data.writeByte(104);
        data.writeByte(items.length);
        for each(var item : ByteArray in items) data.writeBytes(item);
        data.position = 0;
        return data;
    }

    static public function encList(items : Array) : ByteArray {
        var data : ByteArray = new ByteArray();
        data.writeByte(108);
        data.writeInt(items.length);
        for each(var item : ByteArray in items) data.writeBytes(item);
        data.writeByte(106);
        data.position = 0;
        return data;
    }

    static public function decTuple(data : ByteArray) : DecodedData {
        var header : uint = data.readByte();
        if(header != 104) throw new As2BertError("Can't decode Tuple, invalid header:" + header);

        var length : int = data.readByte();
        return decItems(data, length);
    }

    static public function decList(data : ByteArray) : DecodedData {
        var header : uint = data.readByte();
        if(header != 108) throw new As2BertError("Can't decode List, invalid header:" + header);

        var length : int = data.readInt();
        return decItems(data, length);
    }

    static private function decItems(data : ByteArray, length : int) : DecodedData {
        var firstPosition : int = data.position;
        var position : int = data.position;
        var res : DecodedData = new DecodedData();

        for (var i : int = 0; i < length; i++) {
            data.position = position;
            var header : int = data[position];
            var subData : ByteArray = new ByteArray();

            if(header == 97) {
                data.readBytes(subData, 0, 2);
                res.addChar(decChar(subData));
                position += 2;
            }
            else if(header == 98) {
                data.readBytes(subData, 0, 5);
                res.addInt(decInt(subData));
                position += 5;
            }
            else if(header == 99) {
                data.readBytes(subData, 0, 32);
                res.addDouble(decFloat(subData));
                position += 32;
            }
            else if(header == 70) {
                data.readBytes(subData, 0, 9);
                res.addDouble(decDouble(subData));
                position += 9;
            }
            else if(header == 100) {
                data.readBytes(subData, 0, data.length - position);
                var atom : String = decAtom(subData);
                res.addString(atom);
                position += 3 + atom.length;
            }
            else if(header == 106) {
                res.addString("");
                position += 1;
            }
            else if(header == 107) {
                data.readBytes(subData, 0, data.length - position);
                var str : String = decString(subData);
                res.addString(str);
                var b : ByteArray = new ByteArray();
                b.writeUTFBytes(str);
                position += 3 + b.length;
            }
            else if(header == 109) {
                data.readBytes(subData, 0, data.length - position);
                var bin : ByteArray = decBin(subData);
                res.addBinary(bin);
                position += 5 + bin.length;
            }
            else if(header == 104) {
                data.readBytes(subData, 0, data.length - position);
                var tuple : DecodedData = decTuple(subData);
                res.addDecodedData(tuple);
                position += 2 + tuple.binLength;
            }
            else if(header == 108) {
                data.readBytes(subData, 0, data.length - position);
                var list : DecodedData = decList(subData);
                res.addDecodedData(list);
                position += 5 + list.binLength + 1; // plus byte 106 (empty list)
            }
            else {
                var arr : Array = ba2a(data);
                var info : String = res.toString();
                trace("unknown type " + header
                    + " at position " + position + "\n"
                    + "in data " + arr + "\n"
                    + "decoded data so far:\n" + info);
                throw new As2BertError("unknown type " + header + " at position " + position);
            }
        }
        res._binLength = position - firstPosition;
        return res;
    }

    static public function ba2a(data : ByteArray) : Array {
        var arr : Array = [];
        for(var i : int = 0; i < data.length; i++) {
            arr[i] = data[i];
        }
        return arr;
    }
}
}
