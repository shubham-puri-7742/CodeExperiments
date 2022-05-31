using System;
using System.Threading.Tasks;

namespace Parallelism
{
    internal class Program
    {
        // writes the argument a thousand times
        // object parameter (to allow passing the character without a lambda)
        internal static void Write1k(object c)
        {
            for (int i = 0; i < 1000; ++i)
            {
                Console.Write(c);
            }
        }

        // calculates the length of the object (converted to string) passed as an argument
        // object parameter (to allow passing the character without a lambda)
        internal static int TextLen(object o)
        {
            // debug message
            Console.WriteLine($"Task ID: {Task.CurrentId} is processing '{o}'...");
            return o.ToString().Length;
        }
        
        // driver
        public static void Main(string[] args)
        {
            // create a task using the task factory
            Task.Factory.StartNew(() => Write1k('.'));

            // create a task variable and start it
            var t = new Task(() => Write1k("!?!"));
            t.Start();
            
            // call the function
            Write1k(2);

            // blank line
            Console.WriteLine();

            // setup inputs for counting the frequency of lengths in a sentence
            var exampleInput = "Some random and otherwise meaningless input inserted here to test this example on parallelisation";
            // split into words
            var words = exampleInput.Split(' ');
            // arbitrary max length. A real program (for English) may use 50
            const int maxLength = 16;
            // create a new array of counters
            int[] wordLengths = new int[maxLength];

            // process each word using a parallel foreach loop
            Parallel.ForEach(words, word => ++wordLengths[TextLen(word)]);
            
            // blank line
            Console.WriteLine();
            
            // process the word lengths using a parallel for loop 
            Parallel.For(0, maxLength, i => Console.WriteLine($"{wordLengths[i]} words of length {i}"));
            
            // end message
            Console.WriteLine("\nDone Executing");
            Console.ReadKey();
        }
    }
}