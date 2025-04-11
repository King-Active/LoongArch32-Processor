# **LoongArch32 SoC CPU Design**

Designed By:
<br>
Zeng Zhiwen (zwzengi@Outlook.com)
<br>
Shi Chengliang (20221576@stu.cqu.edu.cn)

## **Key Contributions:**  
### **Complete ISA Implementation** 
- Fully compliant with competition specifications, supporting **LoongArch32 instruction set** and **interrupt/exception mechanisms**, achieving **full score in functional tests** and stable performance benchmarking.
### **High-Performance Pipeline**  
- A **5-stage pipeline** with independent optimization modules: **dynamic branch prediction, data forwarding, hazard control, parallel variable-length instruction decoding, and interrupt/exception handling**, ensuring seamless collaboration.  
### **Memory Access Optimization:**  
- **Cache Hierarchy:** Implemented **2-way set-associative iCache** + **4-way set-associative dCache (pseudo-LRU replacement)** + **Victim Cache**, improving data locality.  
- **StoreBuffer Enhancement:** Integrated **StoreTable + StoreFIFO** with **AXI3 burst transfer** and **triple-memory access scheduling**, achieving **>90% hit rate** in quicksort benchmarks, significantly reducing memory latency.  
- **Verification & Performance:** Validated via functional/performance simulations, demonstrating notable speedup in typical workloads and providing a foundation for further optimization.
![dp](https://github.com/user-attachments/assets/5aa3c3ff-5d7d-4f83-9bba-5537c7cc073d)
![cache2](https://github.com/user-attachments/assets/e6641b80-2ec9-4b88-bc78-75eb59312412)
![Cache](https://github.com/user-attachments/assets/82d11289-abf7-44e5-bfed-f849c0ee744d)
![stbf](https://github.com/user-attachments/assets/d7640ebd-8126-46c0-b00b-82ff9e4ddb86)
![st](https://github.com/user-attachments/assets/f43f8eb0-33ca-465a-873a-c524564922a2)
![project](https://github.com/user-attachments/assets/d2dac0a6-267c-4f3f-a8f2-723fb126f662)
![res](https://github.com/user-attachments/assets/a140ea71-1185-403c-af68-7e10fa373940)

