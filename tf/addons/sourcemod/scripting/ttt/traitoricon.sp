/**
 * domination.sp
 * 
 * Provides a per-traitor-only marker by faking the "Domination" icon
 * over each traitor's head for every other traitor.
 */

#pragma semicolon 1

#include <sourcemod>

/**
 * Loop all traitors and send each traitor a "Domination" usermessage
 * for every other traitor, which draws the skull icon only for them.
 */
public void Domination_MarkTraitors()
{
    // build list of traitor clients
    int traitors[32];
    int tcount = 0;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && TTTPlayer(i).role >= TRAITOR)
        {
            traitors[tcount++] = i;
        }
    }

    // for each dominator traitor
    for (int i = 0; i < tcount; i++)
    {
        int dominator = traitors[i];

        // send a Domination msg for each other traitor
        for (int j = 0; j < tcount; j++)
        {
            if (j == i) continue;
            int dominated = traitors[j];

            Handle msg = StartMessageOne("Domination", dominator);
            if (msg)
            {
                BfWriteShort(msg, dominated);
                BfWriteByte(msg, 1);  // show skull
                EndMessage();
            }
        }
    }
}
