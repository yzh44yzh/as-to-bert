package as2bert {

import flash.utils.ByteArray;
import org.flexunit.Assert;

public class NumbersTest {

    [Test]
    public function testEncChar() : void {
        Assert.assertTrue(compare(ba([97, 0]), As2Bert.encChar(0)));
        Assert.assertTrue(compare(ba([97, 10]), As2Bert.encChar(10)));
        Assert.assertTrue(compare(ba([97, 120]), As2Bert.encChar(120)));
        Assert.assertTrue(compare(ba([97, 127]), As2Bert.encChar(127)));
        Assert.assertTrue(compare(ba([97, 128]), As2Bert.encChar(128)));
        Assert.assertTrue(compare(ba([97, 255]), As2Bert.encChar(255)));
        Assert.assertTrue(compare(ba([97, 0]), As2Bert.encChar(256)));
        Assert.assertTrue(compare(ba([97, 4]), As2Bert.encChar(260)));
        Assert.assertTrue(compare(ba([97, 244]), As2Bert.encChar(500)));
    }

    [Test]
    public function testDecChar() : void {
        Assert.assertEquals(0, As2Bert.decChar(ba([97, 0])));
        Assert.assertEquals(2, As2Bert.decChar(ba([97, 2])));
        Assert.assertEquals(99, As2Bert.decChar(ba([97, 99])));
        Assert.assertEquals(127, As2Bert.decChar(ba([97, 127])));
        Assert.assertEquals(128, As2Bert.decChar(ba([97, 128])));
        Assert.assertEquals(255, As2Bert.decChar(ba([97, 255])));
    }

    [Test(expects="as2bert.As2BertError")]
    public function testDecCharInvLength() : void {
        As2Bert.decChar(ba([97]));
    }

    [Test(expects="as2bert.As2BertError")]
    public function testDecCharInvHeader() : void {
        As2Bert.decChar(ba([99, 255]));
    }

    [Test]
    public function testEncInt() : void {
        Assert.assertTrue(compare(ba([98, 0, 0, 0, 0]), As2Bert.encInt(0)));
        Assert.assertTrue(compare(ba([98, 0, 0, 0, 10]), As2Bert.encInt(10)));
        Assert.assertTrue(compare(ba([98, 0, 0, 0, 120]), As2Bert.encInt(120)));
        Assert.assertTrue(compare(ba([98, 0, 0, 0, 127]), As2Bert.encInt(127)));
        Assert.assertTrue(compare(ba([98, 0, 0, 0, 128]), As2Bert.encInt(128)));
        Assert.assertTrue(compare(ba([98, 0, 0, 0, 255]), As2Bert.encInt(255)));
        Assert.assertTrue(compare(ba([98, 0, 0, 1, 0]), As2Bert.encInt(256)));
        Assert.assertTrue(compare(ba([98, 0, 0, 1, 4]), As2Bert.encInt(260)));
        Assert.assertTrue(compare(ba([98, 0, 0, 1, 244]), As2Bert.encInt(500)));
        Assert.assertTrue(compare(ba([98, 0, 0, 3, 255]), As2Bert.encInt(1023)));
        Assert.assertTrue(compare(ba([98, 0, 0, 4, 0]), As2Bert.encInt(1024)));
        Assert.assertTrue(compare(ba([98, 0, 0, 4, 1]), As2Bert.encInt(1025)));
        Assert.assertTrue(compare(ba([98, 0, 0, 255, 255]), As2Bert.encInt(65535)));
        Assert.assertTrue(compare(ba([98, 0, 1, 0, 0]), As2Bert.encInt(65536)));
        Assert.assertTrue(compare(ba([98, 127, 255, 255, 255]), As2Bert.encInt(2147483647)));
        Assert.assertTrue(compare(ba([98, 255, 255, 255, 255]), As2Bert.encInt(-1)));
        Assert.assertTrue(compare(ba([98, 255, 255, 255, 156]), As2Bert.encInt(-100)));
        Assert.assertTrue(compare(ba([98, 255, 255, 252, 0]), As2Bert.encInt(-1024)));
        Assert.assertTrue(compare(ba([98, 128, 0, 0, 0]), As2Bert.encInt(-2147483648)));
    }

    [Test]
    public function testDecInt() : void {
        Assert.assertEquals(0, As2Bert.decInt(ba([98, 0, 0, 0, 0])));
        Assert.assertEquals(2, As2Bert.decInt(ba([98, 0, 0, 0, 2])));
        Assert.assertEquals(99, As2Bert.decInt(ba([98, 0, 0, 0, 99])));
        Assert.assertEquals(127, As2Bert.decInt(ba([98, 0, 0, 0, 127])));
        Assert.assertEquals(128, As2Bert.decInt(ba([98, 0, 0, 0, 128])));
        Assert.assertEquals(255, As2Bert.decInt(ba([98, 0, 0, 0, 255])));
        Assert.assertEquals(256, As2Bert.decInt(ba([98, 0, 0, 1, 0])));
        Assert.assertEquals(260, As2Bert.decInt(ba([98, 0, 0, 1, 4])));
        Assert.assertEquals(500, As2Bert.decInt(ba([98, 0, 0, 1, 244])));
        Assert.assertEquals(1023, As2Bert.decInt(ba([98, 0, 0, 3, 255])));
        Assert.assertEquals(1024, As2Bert.decInt(ba([98, 0, 0, 4, 0])));
        Assert.assertEquals(1025, As2Bert.decInt(ba([98, 0, 0, 4, 1])));
        Assert.assertEquals(65535, As2Bert.decInt(ba([98, 0, 0, 255, 255])));
        Assert.assertEquals(65536, As2Bert.decInt(ba([98, 0, 1, 0, 0])));
        Assert.assertEquals(2147483647, As2Bert.decInt(ba([98, 127, 255, 255, 255])));
        Assert.assertEquals(-1, As2Bert.decInt(ba([98, 255, 255, 255, 255])));
        Assert.assertEquals(-100, As2Bert.decInt(ba([98, 255, 255, 255, 156])));
        Assert.assertEquals(-1024, As2Bert.decInt(ba([98, 255, 255, 252, 0])));
        Assert.assertEquals(-2147483648, As2Bert.decInt(ba([98, 128, 0, 0, 0])));
    }

    [Test(expects="as2bert.As2BertError")]
    public function testDecIntInvLength() : void {
        As2Bert.decChar(ba([98, 1, 1]));
    }

    [Test(expects="as2bert.As2BertError")]
    public function testDecIntInvHeader() : void {
        As2Bert.decChar(ba([99, 1, 1, 1, 1]));
    }

    [Test]
    public function testEncFloat() : void {
        // "5.00000000000000000000e-1"
        var a1 : Array = [99,
            53, 46, 48, 48, 48, 48, 48, 48,
            48, 48, 48, 48, 48, 48, 48, 48,
            48, 48, 48, 48, 48, 48, 101, 45,
            49, 0, 0, 0, 0, 0, 0];
        Assert.assertTrue(compare(ba(a1), As2Bert.encFloat(0.5)));

        // 5.54999999999999982236
        var a2 : Array = [99,
            53, 46, 53, 52, 57, 57, 57, 57,
            57, 57, 57, 57, 57, 57, 57, 57,
            57, 56, 50, 50, 51, 54, 0, 0,
            0, 0, 0, 0, 0, 0, 0];
        Assert.assertTrue(compare(ba(a2), As2Bert.encFloat(5.55)));

        // -1.03499999999999996447e+1
        var a3 : Array = [99,
            45, 49, 46, 48, 51, 52, 57, 57,
            57, 57, 57, 57, 57, 57, 57, 57,
            57, 57, 57, 54, 52, 52, 55, 101,
            43, 49, 0, 0, 0, 0, 0];
        Assert.assertTrue(compare(ba(a3), As2Bert.encFloat(-10.35)));
    }

    [Test]
    public function testDecFloat() : void {
        // "5.00000000000000000000e-01"
        var a1 : Array = [99,
            53, 46, 48, 48, 48, 48, 48, 48,
            48, 48, 48, 48, 48, 48, 48, 48,
            48, 48, 48, 48, 48, 48, 101, 45,
            48, 49, 0, 0, 0, 0, 0];
        Assert.assertEquals(0.5, As2Bert.decFloat(ba(a1)));

        // 5.54999999999999982236e+00
        var a2 : Array = [99,
            53, 46, 53, 52, 57, 57, 57, 57,
            57, 57, 57, 57, 57, 57, 57, 57,
            57, 56, 50, 50, 51, 54, 101, 43,
            48, 48, 0, 0, 0, 0, 0];
        Assert.assertEquals(5.55, As2Bert.decFloat(ba(a2)));

        // -1.03499999999999996447e+01
        var a3 : Array = [99,
            45, 49, 46, 48, 51, 52, 57, 57,
            57, 57, 57, 57, 57, 57, 57, 57,
            57, 57, 57, 54, 52, 52, 55, 101,
            43, 48, 49, 0, 0, 0, 0];
        Assert.assertEquals(-10.35, As2Bert.decFloat(ba(a3)));
    }

    [Test]
    public function testEncDouble() : void {
        var a1 : Array = [70, 63, 224, 0, 0, 0, 0, 0, 0];
        Assert.assertTrue(compare(ba(a1), As2Bert.encDouble(0.5)));

        var a2 : Array = [70, 64, 31, 0, 0, 0, 0, 0, 0];
        Assert.assertTrue(compare(ba(a2), As2Bert.encDouble(7.75)));

        var a3 : Array = [70, 192, 88, 213, 30, 184, 81, 235, 133];
        Assert.assertTrue(compare(ba(a3), As2Bert.encDouble(-99.33)));
    }

    [Test]
    public function testDecDouble() : void {
        var a1 : Array = [70, 63, 224, 0, 0, 0, 0, 0, 0];
        Assert.assertTrue(0.5, As2Bert.decDouble(ba(a1)));

        var a2 : Array = [70, 64, 31, 0, 0, 0, 0, 0, 0];
        Assert.assertTrue(7.75, As2Bert.decDouble(ba(a2)));

        var a3 : Array = [70, 192, 88, 213, 30, 184, 81, 235, 133];
        Assert.assertTrue(-99.33, As2Bert.decDouble(ba(a3)));
    }

    [Test(expects="as2bert.As2BertError")]
    public function testDecFloatInvLength() : void {
        As2Bert.decChar(ba([99, 1, 1]));
    }

    [Test(expects="as2bert.As2BertError")]
    public function testDecFloatInvHeader() : void {
        As2Bert.decChar(ba([11, 1, 1, 1, 1]));
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
