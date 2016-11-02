require "../../spec_helper"

private lib Native
  struct Network
    integer : Int32
    array : Int8[4]
  end
end

private struct Test < Torrent::Util::NetworkOrderStruct(Native::Network)
  fields(
    integer : Int32,
    array : Int8[4],
  )
end

describe "Torrent::Util::NetworkOrderStruct" do
  context "#initialize" do
    it "creates empty instance with no arguments" do
      test = Test.new
      test.integer.should eq 0
      test.array.should eq StaticArray[ 0i8, 0i8, 0i8, 0i8 ]
    end

    it "creates populated instance with a T argument" do
      inner = Native::Network.new
      inner.integer = 0x44332211
      inner.array = StaticArray[ 1i8, 2i8, 3i8, 4i8 ]

      test = Test.new(inner)
      test.integer.should eq 0x11223344
      test.array.should eq StaticArray[ 1i8, 2i8, 3i8, 4i8 ]
    end

    it "creates populated instance with value arguments" do
      test = Test.new(integer: 4, array: StaticArray[ 1i8, 2i8, 3i8, 4i8 ])
      test.integer.should eq 4
      test.array.should eq StaticArray[ 1i8, 2i8, 3i8, 4i8 ]
    end
  end

  context "generated getter" do
    it "passes-through on a non-integer" do
      test = Test.new(integer: 4, array: StaticArray[ 1i8, 2i8, 3i8, 4i8 ])
      test.array.should eq StaticArray[ 1i8, 2i8, 3i8, 4i8 ]
    end

    it "converts integers to host endianess" do
      test = Test.new(integer: 4, array: StaticArray[ 1i8, 2i8, 3i8, 4i8 ])
      test.inner.integer = 0x44332211
      test.integer.should eq 0x11223344
    end
  end

  context "generated setter" do
    it "passes-through on a non-integer" do
      test = Test.new
      test.array = StaticArray[ 1i8, 2i8, 3i8, 4i8 ]
      test.inner.array.should eq StaticArray[ 1i8, 2i8, 3i8, 4i8 ]
    end

    it "converts integers to network endianess" do
      test = Test.new
      test.integer = 0x11223344
      test.inner.integer.should eq 0x44332211
    end
  end

  context "#from" do
    context "on Bytes" do
      it "returns a populated instance" do
        data = StaticArray[ 0x11u8, 0x22u8, 0x33u8, 0x44u8, 0x1u8, 0x2u8, 0x3u8, 0x4u8 ]

        test = Test.from(data.to_slice)
        test.integer.should eq 0x11223344
        test.array.should eq StaticArray[ 1i8, 2i8, 3i8, 4i8 ]
      end
    end

    context "on an IO" do
      it "returns a populated instance" do
        data = StaticArray[ 0x11u8, 0x22u8, 0x33u8, 0x44u8, 0x1u8, 0x2u8, 0x3u8, 0x4u8 ]

        io = MemoryIO.new(data.to_slice)
        test = Test.from(io)
        test.integer.should eq 0x11223344
        test.array.should eq StaticArray[ 1i8, 2i8, 3i8, 4i8 ]
      end
    end
  end
end
