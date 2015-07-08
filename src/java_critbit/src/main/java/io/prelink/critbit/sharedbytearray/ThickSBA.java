package io.prelink.critbit.sharedbytearray;

final class ThickSBA extends AbstractSBA {
    private final byte[] bytes;
    private final int sharedStart;
    private final int sharedEnd;

    public ThickSBA(byte[] bytes, int start, int end) {
        this.bytes = bytes;
        this.sharedStart = start;
        this.sharedEnd = end;
    }

    public int length() {
        return sharedEnd - sharedStart;
    }

    public byte byteAt(int index) {
        if(index < 0 || index >= length()) {
            throw new IndexOutOfBoundsException();
        }
        return bytes[sharedStart + index];
    }

    public SharedByteArray sub(int start, int end) {
        if(start < 0 || end < start || end > length()) {
            throw new IndexOutOfBoundsException();
        }
        if(start == end) {
            return EmptySBA.INSTANCE;
        } else if(start == 0 && end == length()) {
            return this;
        } else {
            return new ThickSBA(bytes, sharedStart + start, sharedStart + end);
        }
    }

    public void toByteArray(int start, byte[] target, int targetStart, int len) {
        if(start < 0 || start+len > length()) {
            throw new IndexOutOfBoundsException();
        }
        System.arraycopy(bytes, sharedStart + start, target, targetStart, len);
    }
}
