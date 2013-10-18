package as2bert {

import flash.utils.ByteArray;

import org.flexunit.Assert;

public class StringsTest {

    [Test]
    public function testEncString() : void {
        Assert.assertTrue(compare(ba([106]), As2Bert.encString("")));

        var a1 : Array = [107, 0, 5, 104, 101, 108, 108, 111];
        Assert.assertTrue(compare(ba(a1), As2Bert.encString("hello")));

        var a2 : Array = [107, 0, 6, 69, 114, 108, 97, 110, 103];
        Assert.assertTrue(compare(ba(a2), As2Bert.encString("Erlang")));

        var a3 : Array = [107, 0, 17, 66, 69, 82, 84, 32, 105,
            115, 32, 116, 104, 101, 32, 98, 101, 115, 116, 33];
        Assert.assertTrue(compare(ba(a3), As2Bert.encString("BERT is the best!")));
    }

    [Test]
    public function testDecString() : void {
        Assert.assertEquals("", As2Bert.decString(ba([106])));

        var a1 : Array = [107, 0, 5, 104, 101, 108, 108, 111];
        Assert.assertEquals("hello", As2Bert.decString(ba(a1)));

        var a2 : Array = [107, 0, 6, 69, 114, 108, 97, 110, 103];
        Assert.assertEquals("Erlang", As2Bert.decString(ba(a2)));

        var a3 : Array = [107, 0, 17, 66, 69, 82, 84, 32, 105,
            115, 32, 116, 104, 101, 32, 98, 101, 115, 116, 33];
        Assert.assertEquals("BERT is the best!", As2Bert.decString(ba(a3)));
    }

    [Test(expects="as2bert.As2BertError")]
    public function testDecStringInvHeader() : void {
        As2Bert.decString(ba([98, 1, 1]));
    }

    [Test]
    public function testEncAtom() : void {
        var a1 : Array = [100, 0, 4, 97, 116, 111, 109];
        Assert.assertTrue(compare(ba(a1), As2Bert.encAtom("atom")));

        var a2 : Array = [100, 0, 8, 117, 115, 101, 114, 110, 97, 109, 101];
        Assert.assertTrue(compare(ba(a2), As2Bert.encAtom("username")));
    }

    [Test]
    public function testDecAtom() : void {
        var a1 : Array = [100, 0, 4, 97, 116, 111, 109];
        Assert.assertEquals("atom", As2Bert.decAtom(ba(a1)));

        var a2 : Array = [100, 0, 8, 117, 115, 101, 114, 110, 97, 109, 101];
        Assert.assertEquals("username", As2Bert.decAtom(ba(a2)));
    }

    [Test]
    public function testEncBin() : void {
        var a1 : Array = [1, 2, 3];
        var a2 : Array = [109, 0, 0, 0, 3, 1, 2, 3];
        Assert.assertTrue(compare(ba(a2), As2Bert.encBin(ba(a1))));

        var a3 : Array = [100, 0, 8, 117, 115, 101, 114, 110, 97, 109, 101];
        var a4 : Array = [109, 0, 0, 0, 11].concat(a3);
        Assert.assertTrue(compare(ba(a4), As2Bert.encBin(ba(a3))));
    }

    [Test]
    public function testDecBin() : void {
        var b1 : ByteArray = ba([1, 2, 3, 4]);
        var b2 : ByteArray = ba([109, 0, 0, 0, 4, 1, 2, 3, 4]);
        Assert.assertTrue(compare(b1, As2Bert.decBin(b2)));

        var a3 : Array = [100, 0, 8, 117, 115, 101, 114, 110, 97, 109, 101];
        var a4 : Array = [109, 0, 0, 0, 11].concat(a3);
        Assert.assertTrue(compare(ba(a3), As2Bert.decBin(ba(a4))));
    }

    [Test]
    public function testEncBStr() : void {
        var b1 : ByteArray = ba([109, 0, 0, 0, 5, 104, 101, 108, 108, 111]);
        Assert.assertTrue(compare(b1, As2Bert.encBStr("hello")));

        var b2 : ByteArray = ba([109, 0, 0, 0, 6, 69, 114, 108, 97, 110, 103]);
        Assert.assertTrue(compare(b2, As2Bert.encBStr("Erlang")));
    }

    [Test]
    public function testDecBStr() : void {
        var b1 : ByteArray = ba([109, 0, 0, 0, 5, 104, 101, 108, 108, 111]);
        Assert.assertEquals("hello", As2Bert.decBStr(b1));

        var b2 : ByteArray = ba([109, 0, 0, 0, 6, 69, 114, 108, 97, 110, 103]);
        Assert.assertEquals("Erlang", As2Bert.decBStr(b2));
    }


    // inner functions

    private function ba(bytes : Array) : ByteArray {
        var data : ByteArray = new ByteArray();
        while(bytes.length) data.writeByte(bytes.shift());
        data.position = 0;
        return data;
    }

    private function compare(b1 : ByteArray, b2 : ByteArray) : Boolean {
        if(b1.length != b2.length) return false;
        for(var i : int = 0; i < b1.length; i++) {
            if(b1[i] != b2[i]) return false;
        }
        return true;
    }
}
}
