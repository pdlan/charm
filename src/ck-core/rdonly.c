/***************************************************************************
 * RCS INFORMATION:
 *
 *	$RCSfile$
 *	$Author$	$Locker$		$State$
 *	$Revision$	$Date$
 *
 ***************************************************************************
 * DESCRIPTION:
 *
 ***************************************************************************
 * REVISION HISTORY:
 *
 * $Log$
 * Revision 2.5  1995-09-07 05:26:49  gursoy
 * made the necessary changes related to CharmInitLoop--> handler fuction
 *
 * Revision 2.4  1995/09/05  22:03:34  sanjeev
 * removed call to CPlus_GetMagicNumber
 *
 * Revision 2.3  1995/07/24  01:54:40  jyelon
 * *** empty log message ***
 *
 * Revision 2.2  1995/07/22  23:45:15  jyelon
 * *** empty log message ***
 *
 * Revision 2.1  1995/06/08  17:07:12  gursoy
 * Cpv macro changes done
 *
 * Revision 1.3  1995/04/21  22:43:18  sanjeev
 * fixed mainchareid bug
 *
 * Revision 1.2  1994/12/01  23:58:02  sanjeev
 * interop stuff
 *
 * Revision 1.1  1994/11/03  17:39:01  brunner
 * Initial revision
 *
 ***************************************************************************/
static char ident[] = "@(#)$Header$";
#include "chare.h"
#include "globals.h"
#include "performance.h"


CpvExtern(char, *ReadBufIndex);
CpvExtern(char, *ReadFromBuffer);

/************************************************************************/
/* The following functions are used to copy the read-buffer out of and 	*/
/* into the read only variables. 					*/
/************************************************************************/
_CK_13CopyToBuffer(srcptr, var_size) 
char *srcptr;
int var_size;
{
  int i;

  for (i=0; i<var_size; i++) 
    *CpvAccess(ReadBufIndex)++ = *srcptr++;
}

_CK_13CopyFromBuffer(destptr, var_size) 
char *destptr;
int var_size;
{
  int i;

  for (i=0; i<var_size; i++) 
    *destptr++ = *CpvAccess(ReadFromBuffer)++;
}


BroadcastReadBuffer(ReadBuffer, size, mainChareBlock)
char *ReadBuffer;
int size;
struct chare_block * mainChareBlock;
{
	ENVELOPE * env;

	env = ENVELOPE_UPTR(ReadBuffer);
	SetEnv_msgType(env, ReadVarMsg);
	
	/* this is where we add the information for the main chare
	block */
	SetEnv_chareBlockPtr(env, (int) mainChareBlock);
	SetEnv_chare_magic_number(env, 
			GetID_chare_magic_number(mainChareBlock->selfID));

        CkCheck_and_BcastInitNL(env);
}


ReadMsgInit(msg, id)
char *msg;
int id;
{
	int packed;
	ENVELOPE *env ;

	env = ENVELOPE_UPTR(msg);
	CpvAccess(NumReadMsg)++;
	SetEnv_msgType(env, ReadMsgMsg);
	SetEnv_other_id(env, id);
	if (GetEnv_isPACKED(env) == UNPACKED)
		packed = 1;
	else
		 packed = 0;

        CkCheck_and_BcastInitNFNL(env); 
}

