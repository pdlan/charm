/*****************************************************************************
 * $Source$
 * $Author$
 * $Date$
 * $Revision$
 *****************************************************************************/

#ifndef _CParseNode_H_
#define _CParseNode_H_

#include "EToken.h"
#include "xi-util.h"
#include "CLexer.h"
#include "sdag-globals.h"
#include "CList.h"
#include "CStateVar.h"
#include "CEntry.h"

class CParser;

class CParseNode {
  public:
    XStr *className;
    void print(int indent);
    int nodeNum;
    XStr *label;
    XStr *counter;
    EToken type;
    XStr *text;
    CParseNode *con1, *con2, *con3, *con4;
    TList *constructs;
    TList *stateVars;
    TList *stateVarsChildren;
    CParseNode *next;
    int nextBeginOrEnd;
    CEntry *entryPtr;
    CParseNode(EToken t, CLexer *cLexer, CParser *cParser);
    CParseNode(EToken t, XStr *txt) : type(t), text(txt), con1(0), con2(0),
                                         con3(0), con4(0), constructs(0) {}
    void numberNodes(void);
    void labelNodes(XStr *);
    void generateEntryList(TList *, CParseNode *);
    void propogateState(TList *);
    void generateCode(XStr& output);
    void setNext(CParseNode *, int);
  private:
    void generateWhen(XStr& op);
    void generateOverlap(XStr& op);
    void generateWhile(XStr& op);
    void generateFor(XStr& op);
    void generateIf(XStr& op);
    void generateElse(XStr& op);
    void generateForall(XStr& op);
    void generateOlist(XStr& op);
    void generateSdagEntry(XStr& op);
    void generateSlist(XStr& op);
    void generateAtomic(XStr& op);
    void generatePrototype(XStr& op, TList *);
    void generateCall(XStr& op, TList *);
};
#endif
