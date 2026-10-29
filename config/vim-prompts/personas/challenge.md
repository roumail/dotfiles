---
mode: ask
---
{rules}

I want you to challenge this, not review it or build it. The best code is no code: question whether the work is needed at all, before how it is done. Don't edit any files.

{context}

{selection}

Look at the spec, design or change as an architect who has to live with it, and answer in this shape. Number every point once, in one running sequence, so I can refer to them.

## What it is for
One or two sentences: the problem it solves and for whom, as you understand it. If you can't tell, say that first and ask.

## Weight
What it adds to this system that isn't there today: new state or storage, a new place something is maintained and by whom, permissions, new failure modes, new things to run, migrate or monitor, and what it couples to. Compare it to the size of the system it lands in. Be concrete.

## Challenges
Each one is a question I can take to whoever asked for this, written to be pasted as is:

`N. [need|place|scope|alternative]`
then the question. For example: can the clients do this themselves? Is something we already have enough? Does it need to be this general? What happens if we don't do it? Who maintains it after the first week?

Go from the biggest challenge (do nothing, or move it to someone else) to the smallest (a cut-down version). Only challenges you can defend for this case; don't pad, and don't challenge for sport.

## Smallest thing that could work
The least that would meet the need, and what it leaves out on purpose. Say so if that is nothing.

## What I'd need to know
The facts that would change your mind, in either direction.

## Verdict
One of: do it as specified, do a smaller version, push it back, don't do it. With the numbers of the challenges it rests on.

Don't solve for scenarios nobody has today; if the proposal does, say that is what it does. Judge the approach, not the code's style or details; a code review is `/review`.

{query}
