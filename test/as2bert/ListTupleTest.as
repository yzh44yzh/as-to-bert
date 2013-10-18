package as2bert {

import flash.utils.ByteArray;

import org.flexunit.Assert;

public class ListTupleTest {

    [Test]
    public function testEncTuple() : void {
        var b1 : ByteArray = ba([104, 2, 97, 5, 97, 6]);
        var a1 : Array = [As2Bert.encChar(5), As2Bert.encChar(6)];
        Assert.assertTrue(compare(b1, As2Bert.encTuple(a1)));

        var b2 : ByteArray = ba([104, 3, 100, 0, 4, 117, 115, 101, 114, 97, 3, 98, 0, 0, 1, 244]);
        var a2 : Array = [As2Bert.encAtom("user"), As2Bert.encChar(3), As2Bert.encInt(500)];
        Assert.assertTrue(compare(b2, As2Bert.encTuple(a2)));
    }

    [Test]
    public function testEncList() : void {
        var b1 : ByteArray = ba([108, 0, 0, 0, 3, 97, 1, 97, 2, 98, 0, 0, 1, 244, 106]);
        var a1 : Array = [As2Bert.encChar(1), As2Bert.encChar(2), As2Bert.encInt(500)];
        Assert.assertTrue(compare(b1, As2Bert.encList(a1)));

        var b2 : ByteArray = ba([108, 0, 0, 0, 4, 97, 1, 97, 2,
            108, 0, 0, 0, 2, 98, 0, 0, 1, 44, 98, 0, 0, 1, 244, 106, 97, 3, 106]);
        var a2 : Array = [As2Bert.encInt(300), As2Bert.encInt(500)];
        var a3 : Array = [As2Bert.encChar(1), As2Bert.encChar(2), As2Bert.encList(a2), As2Bert.encChar(3)];
        Assert.assertTrue(compare(b2, As2Bert.encList(a3)));
    }

    [Test]
    public function testDecTuple() : void {
        var a1 : Array = [104, 3, 97, 5, 97, 6, 98, 0, 0, 1, 244];
        var r1 : DecodedData = As2Bert.decTuple(ba(a1));
        Assert.assertEquals(3, r1.length);
        Assert.assertEquals(9, r1.binLength);
        Assert.assertEquals(5, r1.getChar(0));
        Assert.assertEquals(6, r1.getChar(1));
        Assert.assertEquals(500, r1.getInt(2));

        var a2 : Array = [104, 2, 99, 53, 46, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48,
            48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 101, 45, 48, 49, 0, 0, 0, 0, 0, 97, 10];
        var r2 : DecodedData = As2Bert.decTuple(ba(a2));
        Assert.assertEquals(2, r2.length);
        Assert.assertEquals(34, r2.binLength);
        Assert.assertEquals(0.5, r2.getDouble(0));
        Assert.assertEquals(10, r2.getChar(1));

        var a3 : Array = [104, 4,
            100, 0, 4, 97, 116, 111, 109, // atom 'atom'
            107, 0, 5, 104, 101, 108, 108, 111, // string "hello"
            109, 0, 0, 0, 3, 1, 2, 3, // binary <<1,2,3>>
            97, 10]; // char 10
        var r3 : DecodedData = As2Bert.decTuple(ba(a3));
        Assert.assertEquals(4, r3.length);
        Assert.assertEquals(25, r3.binLength);
        Assert.assertEquals("atom", r3.getString(0));
        Assert.assertEquals("hello", r3.getString(1));
        Assert.assertTrue(compare(ba([1, 2, 3]), r3.getBinary(2)));
        Assert.assertEquals(10, r3.getChar(3));
    }

    [Test]
    public function testDecInnerTuple() : void {
        var a1 : Array = [104, 3,
            97, 5, // char 5
            104, 3, // inner tuple
            97, 5, 97, 6, 98, 0, 0, 1, 244,
            97, 10];
        var r1 : DecodedData = As2Bert.decTuple(ba(a1));
        Assert.assertEquals(3, r1.length);
        Assert.assertEquals(15, r1.binLength);
        Assert.assertEquals(5, r1.getChar(0));
        Assert.assertEquals(10, r1.getChar(2));
        var r2 : DecodedData = r1.getDecodedData(1);
        Assert.assertEquals(3, r2.length);
        Assert.assertEquals(9, r2.binLength);
        Assert.assertEquals(5, r2.getChar(0));
        Assert.assertEquals(6, r2.getChar(1));
        Assert.assertEquals(500, r2.getInt(2));

        var a2 : Array = [104, 4,
            97, 5,
            108, 0, 0, 0, 3, // inner list
            97, 1, 97, 2, 98, 0, 0, 1, 244,
            106, // end of inner list
            97, 7, 97, 20];
        var r3 : DecodedData = As2Bert.decTuple(ba(a2));
        Assert.assertEquals(4, r3.length);
        Assert.assertEquals(21, r3.binLength);
        Assert.assertEquals(5, r3.getChar(0));
        Assert.assertEquals(7, r3.getChar(2));
        Assert.assertEquals(20, r3.getChar(3));
        var r4 : DecodedData = r3.getDecodedData(1);
        Assert.assertEquals(3, r4.length);
        Assert.assertEquals(9, r4.binLength);
        Assert.assertEquals(1, r4.getChar(0));
        Assert.assertEquals(2, r4.getChar(1));
        Assert.assertEquals(500, r4.getInt(2));
    }

    [Test]
    public function testDecList() : void {
        var a1 : Array = [108, 0, 0, 0, 4, 97, 5, 106, 97, 6, 98, 0, 0, 1, 244];
        var r1 : DecodedData = As2Bert.decList(ba(a1));
        Assert.assertEquals(4, r1.length);
        Assert.assertEquals(10, r1.binLength);
        Assert.assertEquals(5, r1.getChar(0));
        Assert.assertEquals("", r1.getString(1));
        Assert.assertEquals(6, r1.getChar(2));
        Assert.assertEquals(500, r1.getInt(3));

        var a2 : Array = [108, 0, 0, 0, 6,
            100, 0, 4, 97, 116, 111, 109, // atom 'atom'
            107, 0, 5, 104, 101, 108, 108, 111, // string "hello"
            109, 0, 0, 0, 3, 1, 2, 3, // binary <<1,2,3>>
            104, 3, 97, 2, 104, 3, 97, 5, 97, 6, 98, 0, 0, 1, 244, 97, 10, // {2, {5, 6, 500}, 10}
            108, 0, 0, 0, 3, 97, 1, 97, 2, 98, 0, 0, 1, 244, 106, // [1, 2, 500]
            97, 10, // char 10
            106];
        var r2 : DecodedData = As2Bert.decList(ba(a2));
        Assert.assertEquals(6, r2.length);
        Assert.assertEquals(57, r2.binLength);
        Assert.assertEquals("atom", r2.getString(0));
        Assert.assertEquals("hello", r2.getString(1));
        Assert.assertTrue(compare(ba([1, 2, 3]), r2.getBinary(2)));
        Assert.assertTrue(10, r2.getChar(5));

        var r3 : DecodedData = r2.getDecodedData(3);
        Assert.assertEquals(3, r3.length);
        Assert.assertEquals(15, r3.binLength);
        Assert.assertTrue(2, r3.getChar(0));
        Assert.assertTrue(10, r3.getChar(2));

        var r4 : DecodedData = r3.getDecodedData(1);
        Assert.assertEquals(3, r4.length);
        Assert.assertEquals(9, r4.binLength);
        Assert.assertTrue(5, r4.getChar(0));
        Assert.assertTrue(6, r4.getChar(1));
        Assert.assertTrue(500, r4.getInt(2));

        var r5 : DecodedData = r2.getDecodedData(4);
        Assert.assertEquals(3, r5.length);
        Assert.assertEquals(9, r5.binLength);
        Assert.assertTrue(1, r5.getChar(0));
        Assert.assertTrue(2, r5.getChar(1));
        Assert.assertTrue(500, r5.getInt(2));
    }

    [Test]
    public function testLoginReply() : void {
        var a : Array = [
            104,6, // tuple of 6
                100,0,5,114,101,112,108,121, // atom 'reply'
                97,1, // cid 1
                97,1, // success 1
                106, // msg ""
                104,3, // tuple of 3, payload
                    104,11, // tuple of 11
                        100,0,4,117,115,101,114, // atom 'user'
                        109,0,0,0,10,116,101,115,116,117,115,101,114,95,49,  // "testuser_1"
                        109,0,0,0,11,84,101,115,116,32,85,115,101,114,32,49, // "Test User 1"
                        109,0,0,0,0, // avatar
                        98,0,3,44,21, // chips
                        98,0,0,2,217, // gold
                        97,1, // pro
                        97,2, // type
                        97,5, // level
                        98,0,0,5,119, // exp
                        109,0,0,0,0, // avatar url
                    97,0, // everyday bonus
                    108,0,0,0,7, // list of 7, Settings
                        104,4, // tuple of 4, bonus prices
                            97,1,
                            97,4,
                            97,3,
                            97,7,
                        104,5, // tuple of 5, bets
                            97,100,
                            97,250,
                            98,0,0,1,244,
                            98,0,0,3,232,
                            98,0,0,19,136,
                        97,5, // add card price
                        97,2, // create table price
                        97,0, // show iAd flag
                        104,5, // tuple of 5, Exp
                            97,1,
                            97,2,
                            97,3,
                            97,5,
                            97,7,
                        108,0,0,0,4, // list of 4, bought bonuses
                            104,2,97,5,97,0,
                            104,2,97,3,97,0,
                            104,2,97,4,97,1,
                            104,2,97,1,97,23,
                        106, // end list of bonuses
                    106, // end list of settings
                97,0 // error_code
        ];
        var reply : DecodedData = As2Bert.decTuple(ba(a));
        Assert.assertEquals(6, reply.length);
        Assert.assertEquals(175, reply.binLength);
        Assert.assertEquals("reply", reply.getString(0));
        Assert.assertEquals(1, reply.getInt(1));
        Assert.assertEquals(1, reply.getChar(2));
        Assert.assertEquals("", reply.getString(3));
        Assert.assertEquals(0, reply.getChar(5));

        var payload : DecodedData = reply.getDecodedData(4);
        Assert.assertEquals(0, payload.getChar(1));

        var user : DecodedData = payload.getDecodedData(0);
        Assert.assertEquals("user", user.getString(0));
        Assert.assertEquals(5, user.getInt(8));

        var settings : DecodedData = payload.getDecodedData(2);
        Assert.assertEquals(1, settings.getDecodedData(0).getChar(0));
        Assert.assertEquals(4, settings.getDecodedData(0).getChar(1));
        Assert.assertEquals(3, settings.getDecodedData(0).getChar(2));
        Assert.assertEquals(7, settings.getDecodedData(0).getChar(3));
        Assert.assertEquals(250, settings.getDecodedData(1).getInt(1));
        Assert.assertEquals(5, settings.getChar(2));
        Assert.assertEquals(0, settings.getChar(4));
        Assert.assertEquals(7, settings.getDecodedData(5).getChar(4));
        Assert.assertEquals(3, settings.getDecodedData(6).getDecodedData(1).getChar(0));
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
