import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;


public class Decompress {
	

	private static int binToInt(String s) {
		Integer i = 0;
		while(s.length() > 0) {
			i *= 2;
			if(s.charAt(0) == '1')
				i += 1;
			s = s.substring(1, s.length());
		}
		return i;
	}
	static class SizeIntPair
	{
		public Integer i;
		public int size;
		
		public SizeIntPair(Integer i1, int size1)
		{
			i = i1;
			size = size1;
		}
	}
	
	private static SizeIntPair getLiteral(int sub8, int sub9) {
		if(sub8 >= 48 && sub8 <= 191)
			return new SizeIntPair(new Integer(sub8 - 48), 8);
		else if(sub9 >= 400 && sub9 <= 511)
			return new SizeIntPair(new Integer(sub9 - 400 + 144), 9);
		return null;
	}
	
	private static SizeIntPair getDistance(int sub5, String extra13bits)
	{
		if(sub5 < 4)
			return new SizeIntPair(new Integer(sub5 + 1), 5);
		else if(sub5 < 6)
		{
			if(extra13bits.charAt(0) == '0')
				return new SizeIntPair(new Integer((sub5 - 4)*2 + 5), 6);
			else
				return new SizeIntPair(new Integer((sub5 - 4)*2 + 6), 6);
		}
		else if(sub5 < 8)
		{
			int k = extra13bits.charAt(0) == '1' ? 2 : 0;
			k += extra13bits.charAt(1) == '1' ? 1 : 0;
			return new SizeIntPair(new Integer((sub5 - 6)*4 + k + 9), 7);
		}
		else if(sub5 < 10)
		{
			int k = extra13bits.charAt(0) == '1' ? 4 : 0;
			k += extra13bits.charAt(1) == '1' ? 2 : 0;
			k += extra13bits.charAt(2) == '1' ? 1 : 0;
			return new SizeIntPair(new Integer((sub5 - 8)*8 + k + 17), 8);
		}
		else if(sub5 < 12)
		{
			int k = extra13bits.charAt(0) == '1' ? 8 : 0;
			k += extra13bits.charAt(1) == '1' ? 4 : 0;
			k += extra13bits.charAt(2) == '1' ? 2 : 0;
			k += extra13bits.charAt(3) == '1' ? 1 : 0;
			return new SizeIntPair(new Integer((sub5 - 10)*16 + k + 33), 9);
		}
		else if(sub5 < 14)
		{
			int k = extra13bits.charAt(0) == '1' ? 16 : 0;
			k += extra13bits.charAt(1) == '1' ? 8 : 0;
			k += extra13bits.charAt(2) == '1' ? 4 : 0;
			k += extra13bits.charAt(3) == '1' ? 2 : 0;
			k += extra13bits.charAt(4) == '1' ? 1 : 0;
			return new SizeIntPair(new Integer((sub5 - 12)*32 + k + 65), 10);
		}
		else if(sub5 < 16)
		{
			int k = extra13bits.charAt(0) == '1' ? 32 : 0;
			k += extra13bits.charAt(1) == '1' ? 16 : 0;
			k += extra13bits.charAt(2) == '1' ? 8 : 0;
			k += extra13bits.charAt(3) == '1' ? 4 : 0;
			k += extra13bits.charAt(4) == '1' ? 2 : 0;
			k += extra13bits.charAt(5) == '1' ? 1 : 0;
			return new SizeIntPair(new Integer((sub5 - 14)*64 + k + 129), 11);
		}
		else if(sub5 < 18)
		{
			int k = extra13bits.charAt(0) == '1' ? 64 : 0;
			k += extra13bits.charAt(1) == '1' ? 32 : 0;
			k += extra13bits.charAt(2) == '1' ? 16 : 0;
			k += extra13bits.charAt(3) == '1' ? 8 : 0;
			k += extra13bits.charAt(4) == '1' ? 4 : 0;
			k += extra13bits.charAt(5) == '1' ? 2 : 0;
			k += extra13bits.charAt(6) == '1' ? 1 : 0;
			return new SizeIntPair(new Integer((sub5 - 16)*128 + k + 257), 12);
		}
		else if(sub5 < 20)
		{
			int k = extra13bits.charAt(0) == '1' ? 128 : 0;
			k += extra13bits.charAt(1) == '1' ? 64 : 0;
			k += extra13bits.charAt(2) == '1' ? 32 : 0;
			k += extra13bits.charAt(3) == '1' ? 16 : 0;
			k += extra13bits.charAt(4) == '1' ? 8 : 0;
			k += extra13bits.charAt(5) == '1' ? 4 : 0;
			k += extra13bits.charAt(6) == '1' ? 2 : 0;
			k += extra13bits.charAt(7) == '1' ? 1 : 0;
			return new SizeIntPair(new Integer((sub5 - 18)*256 + k + 513), 13);
		}
		else if(sub5 < 22)
		{
			int k = extra13bits.charAt(0) == '1' ? 256 : 0;
			k += extra13bits.charAt(1) == '1' ? 128 : 0;
			k += extra13bits.charAt(2) == '1' ? 64 : 0;
			k += extra13bits.charAt(3) == '1' ? 32 : 0;
			k += extra13bits.charAt(4) == '1' ? 16 : 0;
			k += extra13bits.charAt(5) == '1' ? 8 : 0;
			k += extra13bits.charAt(6) == '1' ? 4 : 0;
			k += extra13bits.charAt(7) == '1' ? 2 : 0;
			k += extra13bits.charAt(8) == '1' ? 1 : 0;
			return new SizeIntPair(new Integer((sub5 - 20)*512 + k + 1025), 14);
		}
		else if(sub5 < 24)
		{
			int k = extra13bits.charAt(0) == '1' ? 512 : 0;
			k += extra13bits.charAt(1) == '1' ? 256 : 0;
			k += extra13bits.charAt(2) == '1' ? 128 : 0;
			k += extra13bits.charAt(3) == '1' ? 64 : 0;
			k += extra13bits.charAt(4) == '1' ? 32 : 0;
			k += extra13bits.charAt(5) == '1' ? 16 : 0;
			k += extra13bits.charAt(6) == '1' ? 8 : 0;
			k += extra13bits.charAt(7) == '1' ? 4 : 0;
			k += extra13bits.charAt(8) == '1' ? 2 : 0;
			k += extra13bits.charAt(9) == '1' ? 1 : 0;
			return new SizeIntPair(new Integer((sub5 - 22)*1024 + k + 2049), 15);
		}
		else if(sub5 < 26)
		{
			int k = extra13bits.charAt(0) == '1' ? 1024 : 0;
			k += extra13bits.charAt(1) == '1' ? 512 : 0;
			k += extra13bits.charAt(2) == '1' ? 256 : 0;
			k += extra13bits.charAt(3) == '1' ? 128 : 0;
			k += extra13bits.charAt(4) == '1' ? 64 : 0;
			k += extra13bits.charAt(5) == '1' ? 32 : 0;
			k += extra13bits.charAt(6) == '1' ? 16 : 0;
			k += extra13bits.charAt(7) == '1' ? 8 : 0;
			k += extra13bits.charAt(8) == '1' ? 4 : 0;
			k += extra13bits.charAt(9) == '1' ? 2 : 0;
			k += extra13bits.charAt(10) == '1' ? 1 : 0;
			return new SizeIntPair(new Integer((sub5 - 24)*2048 + k + 4097), 16);
		}
		else if(sub5 < 28)
		{
			int k = extra13bits.charAt(0) == '1' ? 2048 : 0;
			k += extra13bits.charAt(1) == '1' ? 1024 : 0;
			k += extra13bits.charAt(2) == '1' ? 512 : 0;
			k += extra13bits.charAt(3) == '1' ? 256 : 0;
			k += extra13bits.charAt(4) == '1' ? 128 : 0;
			k += extra13bits.charAt(5) == '1' ? 64 : 0;
			k += extra13bits.charAt(6) == '1' ? 32 : 0;
			k += extra13bits.charAt(7) == '1' ? 16 : 0;
			k += extra13bits.charAt(8) == '1' ? 8 : 0;
			k += extra13bits.charAt(9) == '1' ? 4 : 0;
			k += extra13bits.charAt(10) == '1' ? 2 : 0;
			k += extra13bits.charAt(11) == '1' ? 1 : 0;
			return new SizeIntPair(new Integer((sub5 - 26)*4096 + k + 8193), 17);
		}
		else if(sub5 < 30)
		{
			int k = extra13bits.charAt(0) == '1' ? 4096 : 0;
			k += extra13bits.charAt(1) == '1' ? 2048 : 0;
			k += extra13bits.charAt(2) == '1' ? 1024 : 0;
			k += extra13bits.charAt(3) == '1' ? 512 : 0;
			k += extra13bits.charAt(4) == '1' ? 256 : 0;
			k += extra13bits.charAt(5) == '1' ? 128 : 0;
			k += extra13bits.charAt(6) == '1' ? 64 : 0;
			k += extra13bits.charAt(7) == '1' ? 32 : 0;
			k += extra13bits.charAt(8) == '1' ? 16 : 0;
			k += extra13bits.charAt(9) == '1' ? 8 : 0;
			k += extra13bits.charAt(10) == '1' ? 4 : 0;
			k += extra13bits.charAt(11) == '1' ? 2 : 0;
			k += extra13bits.charAt(12) == '1' ? 1 : 0;
			return new SizeIntPair(new Integer((sub5 - 28)*8192 + k + 16385), 18);
		}
		return null;
	}
	
	private static SizeIntPair getLength(int sub7, int sub8, String next5) {
		if(sub7 >=0 && sub7 <= 23) {
			if(sub7 <= 8)//0 extra
				return new SizeIntPair(new Integer(sub7 + 2), 7);
			else if(sub7 <= 12) //1 extra
			{
				if(next5.charAt(0) == '0')
					return new SizeIntPair(new Integer((sub7 - 9)*2 + 11), 8);
				else
					return new SizeIntPair(new Integer((sub7 - 9)*2 + 12), 8);
			}
			else if(sub7 <= 16) //2 extra
			{
				int k = next5.charAt(0) == '1' ? 2 : 0;
				k += next5.charAt(1) == '1' ? 1 : 0;
				return new SizeIntPair(new Integer((sub7 - 13)*4 + 19 + k), 9);
			}
			else if(sub7 <= 20) //3 extra
			{
				int k = next5.charAt(0) == '1' ? 4 : 0;
				k += next5.charAt(1) == '1' ? 2 : 0;
				k += next5.charAt(2) == '1' ? 1 : 0;
				return new SizeIntPair(new Integer((sub7 - 17)*8 + 35 + k), 10);
			}
			else //4 extra
			{
				int k = next5.charAt(0) == '1' ? 8 : 0;
				k += next5.charAt(1) == '1' ? 4 : 0;
				k += next5.charAt(2) == '1' ? 2 : 0;
				k += next5.charAt(3) == '1' ? 1 : 0;
				return new SizeIntPair(new Integer((sub7 - 21)*16 + 67 + k), 11);
			}
		}
		else if(sub8 >= 192 && sub8 <= 199) {
			if(sub8 == 192) //4 extra
			{
				int k = next5.charAt(1) == '1' ? 8 : 0;
				k += next5.charAt(2) == '1' ? 4 : 0;
				k += next5.charAt(3) == '1' ? 2 : 0;
				k += next5.charAt(4) == '1' ? 1 : 0;
				return new SizeIntPair(new Integer(115 + k), 12);
			}
			else if(sub8 <= 196) //5 extra
			{
				int k = next5.charAt(1) == '1' ? 16 : 0;
				k += next5.charAt(2) == '1' ? 8 : 0;
				k += next5.charAt(3) == '1' ? 4 : 0;
				k += next5.charAt(4) == '1' ? 2 : 0;
				k += next5.charAt(5) == '1' ? 1 : 0;
				return new SizeIntPair(new Integer((sub8 - 193)*32 + 131 + k), 13);
			}
			else if(sub8 == 197) //0 extra
				return new SizeIntPair(new Integer(258), 8);
		}
		return null;
	}
	
	
	public static String decompress(String s) {
		String d = new String();
		
		double bitsIn = s.length();
		int lenLast = 0;

		while(s.length() > 20) //extra long to make sure
		{

			int sub5 = binToInt(s.substring(0, 5));
			int sub7 = binToInt(s.substring(0, 7));
			int sub8 = binToInt(s.substring(0, 8));
			int sub9 = binToInt(s.substring(0, 9));
			
			SizeIntPair lit = getLiteral(sub8, sub9);
			SizeIntPair len = getLength(sub7, sub8, s.substring(7, 13));
			SizeIntPair dist = getDistance(sub5, s.substring(5, 18));
			
			if(lit != null && len == null && lenLast == 0)
			{
				lenLast = 0;
				System.out.println("Literal: " + (int) lit.i);
				s = s.substring(lit.size, s.length());
				d += (char) (int) lit.i;
			}
			else if(len != null && lit == null && lenLast == 0)
			{
				lenLast = len.i;
				s = s.substring(len.size, s.length());
			}
			else if(dist != null && lenLast != 0)
			{
				s = s.substring(dist.size, s.length());
				int b = d.length() - dist.i;
				int e = d.length() - dist.i + lenLast;
				System.out.println("D: " + dist.i + " L: " + lenLast);
				if(e > d.length() || dist.i > d.length()) d += d.substring(0, lenLast);
				else d += d.substring(b, e);
				lenLast = 0;
			}
			else if(lit != null &&  len != null)
			{
				System.out.println("Huffman Error");
				break;
			}
			else 
			{
				break;
			}
			
		}
		bitsIn -= s.length();
		System.out.println("Ratio: " + bitsIn/d.length()/8);
		return d;
	}
	
	public static void main(String[] args) {
		String content;
		try {
			content = new String(Files.readAllBytes(
					Paths.get(args[0])), 
					Charset.defaultCharset());
			String s = decompress(content);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}


