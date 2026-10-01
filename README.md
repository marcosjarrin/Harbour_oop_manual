# Object-Oriented Programming in Harbour: A Comprehensive Manual


For over three decades, the xBase family (Clipper, FoxPro, Harbour) has powered mission-critical business applications worldwide. Yet, its full potential in **object-oriented programming (OOP)** remains underexplored. This book bridges that gap.  

## **Why This Book?**  
Harbour—a modern, open-source successor to Clipper—combines xBase’s legendary efficiency with robust OOP capabilities. Unlike generic OOP guides, this manual:  
✔ **Targets Harbour specifically**, with code tested on Harbour 3.0+ and xHarbour  
✔ Balances **theory** (SOLID principles) with **practice** (DBF integration, TUI/GUI examples)  
✔ Covers **unique xBase quirks** (e.g., simulated abstract classes via `METHOD VIRTUAL`)  

## **Who Is This For?**  
- **Legacy developers** transitioning from procedural xBase to OOP  
- **Modern programmers** exploring Harbour’s unique blend of speed and OOP flexibility  
- **Computer science students** studying OOP implementation in dynamic languages  

## **What You’ll Learn**  
Your journey through OOP mastery includes:  

### **Foundations (Chapters 1–4)**  
- How Harbour’s `CLASS` syntax differs from C++/Java (Chapter 2)  
- **Encapsulation patterns** for DBF-backed applications (Chapter 4)  
- The truth about Harbour’s **destructor-less** memory management (Chapter 2.5)  

### **Advanced Techniques (Chapters 5–7)**  
- **Inheritance hierarchies** for business objects (e.g., `Invoice → TaxInvoice`)  
- **Polymorphic designs** without traditional interfaces (Chapter 6.4)  
- **xBase-compatible abstraction** using `METHOD VIRTUAL RAISE` (Chapter 7)  

## **Code Philosophy**  
Every example follows these standards:  
```harbour
/**
 * CLASS: cAccount  
 * Demonstrates encapsulation with transaction logging  
 */
CLASS CAccount  
   PROTECTED:  
   DATA nBalance INIT 0  
   EXPORTED:  
   METHOD Deposit(nAmount)  
   METHOD GetBalance() INLINE ::nBalance  
ENDCLASS  
```  
- **Commented for pedagogy**: Javadoc-style + inline explanations  
- **Production-ready**: Error handling (`TRY/CATCH`), DB transactions  
- **Modular**: Accompanying GitHub repo with buildable projects  

## **Beyond Syntax**  
This book emphasizes **design thinking**:  
- When to use composition over inheritance in Harbour  
- How OOP simplifies legacy DBF migration  
- Performance implications of Harbour’s dynamic dispatch  

## **Let’s Begin**  
Whether you’re modernizing a 1990s Clipper system or building new high-performance applications, Harbour’s OOP tools offer surprising power. Turn to **Chapter 1** to start your journey—or jump to **Chapter 5** if you’re already familiar with OOP basics.  

**Why Harbour for OOP in 2025?**  
> *“Harbour’s OOP retains xBase’s file-level compatibility while enabling modern patterns.

-----

The manual is not complete; new chapters could be added. Complete program examples are found in the Examples folder, and will be added over time.
We need the community's help to make this manual as accurate and complete as possible. If you find any errors, please leave an issue so we can correct them. If you can, please contribute examples to make the manual as complete as possible.

Examples:
**Terminal interface
Harbor MiniGUI Extended Edition interface**

Marcos Jarrin
