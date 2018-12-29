1. Load up look_at_the clerks.sql to show how to observe which memory clerks are using
the most memory. It is very natural for the top 3 to be buffer pool and proc cache.
2. Mention I have two event sessions: memory_tracing and memory_leak_detection. I'll explain
once I run the repro why the two
3. Start both of these sessions
4. Run repro.cmd
5. Observe the top clerk consumers. Which clerk is "climbing" to the top? Should this clerk
be using that much memory?
6. Look at the results of the memory_tracing session. At least we know what query is using
that clerk. But is it a leak?
7. Now look at the results of the memory_leak_detection and talk about how the pairing target
proves this is a leak
