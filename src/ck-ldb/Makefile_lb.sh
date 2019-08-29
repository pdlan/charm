#!/bin/sh

#Typical load balancers
COMMON_LDBS="DummyLB GreedyLB GreedyRefineLB CommLB RandCentLB RefineLB RefineCommLB RotateLB DistributedLB HierarchicalLB HybridLB ComboCentLB RefineSwapLB NeighborLB OrbLB BlockLB GreedyCommLB NodeLevelLB"
#Load balancers for more specialized circumstances
SPECIALIZED_LDBS="GraphPartLB GraphBFTLB GridCommLB GridCommRefineLB HbmLB RefineKLB  TempAwareCommLB TreeMatchLB GreedyAgentLB NeighborCommLB PhasebyArrayLB RecBipartLB CommAwareRefineLB AdaptiveLB MetisLB GridMetisLB"
#Load balanders which have an external dependency, or require some other kind of intervention
UNCOMMON_LDBS="ScotchLB TeamLB WSLB TempAwareGreedyLB GridHybridSeedLB TopoCentLB GridHybridLB TopoLB RefineTopoLB TempAwareRefineLB"

ALL_LDBS="$COMMON_LDBS $SPECIALIZED_LDBS"

out="Make.lb"

echo "# Automatically generated by script Makefile_lb.sh" > $out
echo "COMMON_LDBS=\\" >> $out
for bal in $COMMON_LDBS 
do 
	echo "   $bal \\" >> $out 
done
echo "   manager.o" >> $out
echo >> $out

echo "ALL_LDBS=\\" >> $out
for bal in $ALL_LDBS 
do 
	echo "   $bal \\" >> $out 
done
echo "   manager.o" >> $out
echo >> $out

for bal in $ALL_LDBS $UNCOMMON_LDBS
do 
        manager=""
        [ $bal = 'GreedyCommLB' ] && manager="manager.o"
        [ $bal = 'GridCommLB' ] && manager="manager.o"
        [ $bal = 'GridCommRefineLB' ] && manager="manager.o"
        [ $bal = 'GridHybridLB' ] && manager="manager.o"
        [ $bal = 'GridHybridSeedLB' ] && manager="manager.o"
        [ $bal = 'TreeMatchLB' ] && manager="tm_tree.o tm_bucket.o tm_timings.o tm_mapping.o"

#implicit make rules exist for xxxxLB, we override them so users can choose
#make xxxxLB if they only want to build one without the kitchen sink of EveryLB

	cat >> $out << EOB 
\$(L)/libmodule$bal.a: $manager
LBHEADERS += $bal.h $bal.decl.h

EOB
done

echo "// AUTOMATICALLY GENERATED FILE" > EveryLB.ci
echo "" >> EveryLB.ci
echo "module EveryLB {" >> EveryLB.ci
for bal in $ALL_LDBS
do
	echo "  extern module $bal;" >> EveryLB.ci
done
echo "" >> EveryLB.ci
echo "  initnode void initEveryLB(void);" >> EveryLB.ci
echo "};" >> EveryLB.ci

echo "// AUTOMATICALLY GENERATED FILE" > CommonLBs.ci
echo "" >> CommonLBs.ci
echo "module CommonLBs {" >> CommonLBs.ci
for bal in $COMMON_LDBS
do
        echo "  extern module $bal;" >> CommonLBs.ci
done
echo "" >> CommonLBs.ci
echo "  initnode void initCommonLBs(void);" >> CommonLBs.ci
echo "};" >> CommonLBs.ci

echo "# used for make depends" >> $out
echo "ALL_LB_OBJS=EveryLB.o \\" >> $out
echo "    CommonLBs.o \\" >> $out
for bal in $ALL_LDBS $UNCOMMON_LDBS
do
	echo "    $bal.o \\" >> $out
done
echo "    manager.o  \\" >> $out
echo "    tm_tree.o  \\" >> $out
echo "    tm_timings.o  \\" >> $out
echo "    tm_bucket.o \\" >> $out
echo "    tm_mapping.o" >> $out

echo "# EveryLB dependecies" >> $out
echo "EVERYLB_DEPS=EveryLB.o \\" >> $out
for bal in $ALL_LDBS
do
	echo "    $bal.o \\" >> $out
done
echo "    manager.o \\" >> $out
echo "    tm_tree.o  \\" >> $out
echo "    tm_timings.o  \\" >> $out
echo "    tm_bucket.o \\" >> $out
echo "    tm_mapping.o" >> $out

echo "# CommonLBs dependencies" >> $out
echo "COMMONLBS_DEPS=CommonLBs.o \\" >> $out
for bal in $COMMON_LDBS
do
	echo "    $bal.o \\" >> $out
done
echo "    manager.o" \\>> $out

# The badly formed implicit make rules for EveryLB and CommonLB are
# explicitly redefined so that they do right thing (make a proper
# libmodule).  This also allows us to use them in the primary Makefile
# in an intuitive manner.

cat >> $out <<EOB

\$(L)/libmoduleEveryLB.a: \$(EVERYLB_DEPS)
\$(L)/libmoduleCommonLBs.a: \$(COMMONLBS_DEPS)
CommonLBs: \$(L)/libmoduleCommonLBs.a
	@true
EOB
