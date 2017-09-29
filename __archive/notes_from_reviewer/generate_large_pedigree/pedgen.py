#!/usr/bin/env python3

from sys import argv
from random import random, choice, randint
from math import floor, ceil

max_num_members = int( argv[1] )

class Person:
    id_map = {}
    pers_map = {}

    def __init__(self, id, gender, mother, father, affect, mat_all = None, pat_all = None):
        self.id = int(id)
        self.mother = mother
        self.father = father
        self.gender = int(gender)
        self.affect = int(affect)

        self.has_partner_and_kids = False # has both or neither
        self.children = []

        self.mat_allele = mat_all;
        self.pat_allele = pat_all
        Person.pers_map[id] = self
        

    def getGeneration(self):
        return int(str(self.id)[0])

    @staticmethod
    def randomAttrib():
        return randint(1,2)


    @staticmethod
    def randomChildFromParents(mat, pat):
        mat_gener = mat.getGeneration()
        pat_gener = pat.getGeneration()

        larger = mat_gener if mat_gener > pat_gener else pat_gener
        new_gener = larger + 1
        new_gender = Person.randomAttrib()

        new_id = Person.newid( new_gener, new_gender)

        # Perform meiosis to work out who is affected
        all1 = Allele.meiosis(mat.mat_allele, mat.pat_allele)
        all2 = Allele.meiosis(pat.mat_allele, pat.pat_allele)

        affected = (all1 == Allele.allele_disease) or (all2 == Allele.allele_disease)
        
        return Person(new_id, new_gender, mat, pat, affected, all1, all2)
        
        
    
    @staticmethod
    def newid(generation, gender, modif = 1):
        ext = gender * modif  # females even, males odd
        num = (generation * 1000) + ext

        if generation not in Person.id_map:
            Person.id_map[generation] = {}

        if num not in Person.id_map[generation]:
            Person.id_map[generation][num] = True
        else:
            return Person.newid(generation, gender, modif + 1) # recurse until its not

        return num



class Allele:

    allele_disease = [1,1,1,2,2,1,1,2,2,1,1,2,2,1,1,1]

    @staticmethod
    def new_nondisease_allele():
        new_all = [ randint(1,2) for x in range(16)]

        if new_all == Allele.allele_disease:
            return Allele.new_nondisease_allele()
        return new_all


    @staticmethod
    def meiosis(all1,all2):
        
        if len(all1) != len(all2):
            print("Allele lengths do not match", all1, all2)
            exit(-1)

        buff = 5
        all_len = buff + len(all1) + buff
        # Add a buffer of 5 on each side, if number falls in 0:5 or -5:-1, then no recombination occurs
        index_split = floor(random() * all_len )

        if index_split < buff:
            return all1

        if index_split > all_len - buff:
            return all2

        #otherwise recombine
        index_split -= buff
        return all1[:index_split] + all2[index_split:]
        


class IndividualLib:

    max_offspring = 5
    min_offspring = 0 # 0, but -5 centers the random distribution

    @staticmethod
    def makeFounder(generation, gender = None, affected=False):
        if gender == None:
            gender = Person.randomAttrib()
        
        _id = Person.newid(generation, gender)
        _a1 = Allele.new_nondisease_allele()
        _a2 = Allele.new_nondisease_allele()

        if affected:
            _a1 = Allele.allele_disease

        return Person( _id, gender, None  , None  , affected,
                       _a1,
                       _a2)

    
    @staticmethod    
    def makeFounderCouple(generation, mat_affected = False, pat_affected = False):
        return (
            IndividualLib.makeFounder(generation, 2, mat_affected),
            IndividualLib.makeFounder(generation, 1, pat_affected)
        )

    
    @staticmethod
    def makeSingleChild(mat,pat):
        return Person.randomChildFromParents(mat, pat)
   

    @staticmethod
    def makeOffspring(mat, pat):
        num_off = randint(IndividualLib.min_offspring, IndividualLib.max_offspring)

        #print("num_off", num_off)
    
        offspr = []
        for ng in range(num_off):
            offspr.append( IndividualLib.makeSingleChild(mat,pat)  )

        return offspr


    @staticmethod
    def getIdsOfAncestors(indiv, ancestor_map):  #  to be populated
        ancestor_map[indiv.id] = True

        for child in indiv.children:
            IndividualLib.getIdsOfAncestors(child, ancestor_map)
        
        

    @staticmethod
    def findMate(my, inbreed_chance):
        inbred = inbreed_chance < random()

        partner = None
        if inbred:
            partner = IndividualLib.findAttractiveAvailableCousin(my)

        if partner == None:
            partner_gender = 2 if my.gender == 1 else 1
            partner_genera = my.getGeneration()
            partner = IndividualLib.makeFounder( partner_genera, partner_gender, False) # new mates into a family are not affected

        return partner
                               

    
    @staticmethod
    def findAttractiveAvailableCousin(my):
        my_gener = my.getGeneration()
        cousins = Person.id_map[my_gener]  # people of the same generation

        for c in cousins:
            cuz = Person.pers_map[c]
            if cuz.mother != None:
                if (cuz.mother.id, cuz.father.id) != (my.mother.id, my.father.id):  # not a sib, woo
                    if cuz.gender != my.gender:                      # straight
                        if not cuz.has_partner_and_kids:             # single
                            print("Inbreeding:", my.id, cuz.id)
                            return cuz

        return None


#chance_of_inbreeding=0.2   # each new couple has a chance of marrying a relative (without same parents)

class Generator:

    def __init__(self):
        self.max_root_foundercouples = 3
        self.min_root_foundercouples = 1
        self.chance_of_inbreeding    = 0.2   # each new couple has a chance of marrying a relative (same parents)
        self.num_peeps = 0


    @staticmethod
    def germinate( indiv, num_members, chance_of_inbreeding ):
        num_members -= 1

        if (num_members <= 0):
            return
        
        giveMate = 0.5 <= random()

        print("giveMate", giveMate)
        
        if giveMate:
            partner = IndividualLib.findMate( indiv, chance_of_inbreeding)
            num_members -= 1
            
            mat = None;
            pat = None;
            if indiv.gender == 2:
                mat = indiv
                pat = partner
            else:
                mat = partner
                pat = indiv

                
            kids = IndividualLib.makeOffspring( mat, pat )
            #print("kids", kids)

            for kid in kids:
                Generator.germinate( kid, num_members, chance_of_inbreeding )

        # No mate given, trail ends here
        return

        

    def run(self):
        self.trails = []

        seed_foundercouples = self.min_root_foundercouples + floor(
            random() *  (self.max_root_foundercouples - self.min_root_foundercouples)
        )

        iterate = seed_foundercouples

        while iterate > 0:
            Generator.germinate(
                IndividualLib.makeFounder(1),         # first root fills a tree with members, subsequent roots mingle
                max_num_members / seed_foundercouples,# each root tree should have total_people / num_trees members
                self.chance_of_inbreeding
            )
            iterate -= 1

        #import pdb
        #pdb.set_trace()



g = Generator()
g.run()




