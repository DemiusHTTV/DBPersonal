interface Test1 {
    Name: string;
    age: number;
}

interface Test2 {
    Name_age: string;
}

function createTest1(count: number): Test1[] {
    const result: Test1[] = [];
    for (let i = 1; i <= count; i++) {
        result.push({ Name: `User${i}`, age: i });
    }
    return result;
}

function getTest2FromTest1(test1: Test1[]): Test2[] {
    return test1.map((item) => ({
        Name_age: `${item.Name}_${item.age}`,
    }));
}

const test1 = createTest1(100);
const test2 = getTest2FromTest1(test1);

console.log("test1:", test1.length, "эл");
console.log(test1.slice(0, 3));

console.log("test2:", test2.length, "эл");
console.log(test2.slice(0, 3));
