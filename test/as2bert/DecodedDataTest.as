package as2bert {

import flash.utils.ByteArray;

import org.flexunit.Assert;

public class DecodedDataTest {

    [Test]
    public function testAddGet() : void {
        var data : DecodedData = new DecodedData();
        data.addChar(1);
        data.addInt(2);
        data.addDouble(0.5);
        data.addString("Hello");

        var b : ByteArray = new ByteArray();
        b.writeByte(1);
        data.addBinary(b);

        var d : DecodedData = new DecodedData();
        d.addChar(10);
        data.addDecodedData(d);

        Assert.assertEquals(1, data.getChar(0));
        Assert.assertEquals(1, data.getInt(0));
        Assert.assertEquals(2, data.getInt(1));
        Assert.assertEquals(0.5, data.getDouble(2));
        Assert.assertEquals("Hello", data.getString(3));
        Assert.assertEquals(b, data.getBinary(4));
        Assert.assertEquals(d, data.getDecodedData(5));
        Assert.assertEquals(10, data.getDecodedData(5).getChar(0));
    }

    [Test(expects="as2bert.As2BertError")]
    public function testCheckType() : void {
        var data : DecodedData = new DecodedData();
        data.addChar(1);
        data.getDouble(0);
    }

    [Test]
    public function toStringTest() : void {
        var data : DecodedData = new DecodedData();
        data.addChar(15);
        data.addString("hello");
        var str : String = "DecodedData--\n"
            + "----0-Char--15\n"
            + "----1-String--\"hello\"\n";
        Assert.assertEquals(str, data.toString());

        var data2 : DecodedData = new DecodedData();
        data2.addDouble(1.5);
        data2.addDecodedData(data);
        data2.addInt(55);
        data2.addDecodedData(null);
        var b : ByteArray = new ByteArray();
        b.writeByte(1);
        b.writeByte(2);
        b.writeByte(3);
        data2.addBinary(b);
        data2.addBinary(null);
        var str2 : String = "DecodedData--\n"
            + "----0-Double--1.5\n"
            + "----1-DecodedData--\n"
            + "----1-----0-Char--15\n"
            + "----1-----1-String--\"hello\"\n"
            + "----2-Int--55\n"
            + "----3-DecodedData--<null>\n"
            + "----4-Binary--<1,2,3>\n"
            + "----5-Binary--<null>\n"
        Assert.assertEquals(str2, data2.toString());
    }
}
}
