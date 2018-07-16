#!/usr/bin/python
import collections
import sys
from typing import Dict, List, NamedTuple, Set, Tuple


ID = str


class Member(NamedTuple):
    id: ID
    static: bool
    name: str
    fpath: str
    line: int
    stack: int


Members = Dict[ID, Member]
Dependencies = Dict[ID, Set[ID]]


class GccStackUsageKey(NamedTuple):
    fname: str
    line: int
    name: str


GccStackUsages = Dict[GccStackUsageKey, int]


def read_gccstacks(tsv_fpath: str) -> GccStackUsages:
    ret: GccStackUsages = dict()
    with open(tsv_fpath) as tsv_file:
        for line in tsv_file:
            try:
                (src, stack, scope) = line.rstrip().split()
                (fname, line, column, name) = src.split(':')
            except ValueError:
                continue
            m = GccStackUsageKey(fname, int(line), name)
            ret[m] = int(stack)
    return ret


def read_members(tsv_fpath: str, stacks: GccStackUsages) -> Members:
    member: Members = dict()
    with open(tsv_fpath) as member_file:
        for line in member_file:
            if line.startswith("#"):
                continue
            try:
                (id, kind, static, name, fpath, line) = line.rstrip().split()
            except ValueError:
                continue
            if kind != 'function':
                continue
            k = GccStackUsageKey(fpath.split('/')[-1], int(line), name)
            if k not in stacks:
                print("Stack data notfound: "+str(k))
                continue
            m = Member(id, static == "yes", name, fpath, int(line), stacks[k])
            member[m.id] = m
    return member


def read_deps(tsv_fpath: str) -> Dependencies:
    dep: Dependencies = collections.defaultdict(set)
    with open(tsv_fpath) as tsv_file:
        for line in tsv_file:
            if line.startswith("#"):
                continue
            try:
                (src, dst) = line.rstrip().split()
            except ValueError:
                continue
            dep[src].add(dst)
    return dep


cache: Dict[ID, Tuple[int, List[Member]]] = dict()


def walk(calls: List[Member], dep: Dependencies,
         members: Members) -> Tuple[int, List[Member]]:
    me = calls[-1]
    if me.id in cache:
        return cache[me.id]
    if me in calls[:-1]:
        cache[me.id] = (-1, calls)
        print("recurcive : " + ", ".join(f'{f.fpath}:{f.name}' for f in calls))
        return (-1, calls)
    now_max: Tuple[int, List[Member]] = (-1, [])
    for m in dep[me.id]:
        if m not in members:
            continue
        dst = members[m]
        tmp = walk(calls+[dst], dep, members)
        if now_max[0] < tmp[0]:
            now_max = tmp
    ret = (me.stack+now_max[0], [me]+now_max[1])
    cache[me.id] = ret
    return ret


def run(member_fpath: str, dep_fpath: str, stack_fapth: str,
        entrypoint: str = 'main', entryfpath: str = "") -> None:
    stacks = read_gccstacks(stack_fapth)
    member = read_members(member_fpath, stacks)
    del stacks
    dep = read_deps(dep_fpath)

    def member_match(m: Member) -> bool:
        fpath_matched = ((entryfpath == "") or
                         (m.fpath == entryfpath))
        return (m.name == entrypoint) and fpath_matched
    # find entry
    entries = list(filter(member_match, member.values()))
    if len(entries) > 1:
        print('Multiple entry found.')
        for m in entries:
            print(f'  {m.name}\t{m.fpath}')
    elif len(entries) == 0:
        print('Entrypoint not found.')
        return
    entry = entries[0]
    print(f'Entrypoint {entry.fpath}:{entry.name}')
    result = walk([entry], dep, member)
    print(f'Total stack usage: {result[0]}')
    print('Callstack:')
    for m in result[1]:
        print(f'  {m.fpath}:{m.line}:{m.name} {m.stack}')


def main(argv: List[str]) -> int:
    run(*argv[1:])
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
