1. Load up dmvs.sql
2. Run stresstemp.cmd
3. Run query to see the PAGELATCH waits. What are the page numbers?
4. What is the resource_address in this output?
5. Run dbccpage.sql and see if this resource address is 0x80 bytes from the BUF address
