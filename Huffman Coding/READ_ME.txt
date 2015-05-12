Huffman_Top is the top module for the Huffman Trees.  
The reference to the static trees and how they work is in Reference_Tables.png

Huffman_Top will output the encoded value and the number of bits at the next clock cycle.
If one of distance/length/literal are high then it will encode at the next clock cycle.
If none or multiple or high the output will be all zeros.